//
//  GSSSession.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSession.h"
#import "GSParseQueryHelper.h"
#import "NSData+Base64.h"
#import "SVProgressHUD.h"
#import "GSObject.h"

#define kFireBaseBaseURL @"https://gg.firebaseio.com/"
#define kMaxSizeFirebaseString 10485760

static GSSession *activeSession = nil;

@interface GSSession()
- (void)linkFacebookDataBlock:(GSResultBlock)block;
- (void)initEssentialDataBlock:(GSResultBlock)block;
- (void)setUserInitialApp;
- (void)initOrUpdateGSUser;
- (void)updateUserDataWithBlock:(GSResultBlock)block;
- (Firebase *)getMyBaseFirebase;
- (Firebase *)generateFirebaseFor:(GSUser *)user atTime:(NSString *)time;
@property (nonatomic, retain) Firebase *firebase;
@end

@implementation GSSession
@synthesize firebase = _firebase;
@synthesize delegate = _delegate;
@synthesize currentUser = _currentUser;

+ (GSSession *)activeSession {
    static GSSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [GSSession new]; });
    return activeSession;
}

- (id)init {
    if (self = [super init]) {
        if ([PFUser currentUser]) {
            [self initOrUpdateGSUser];
        }
    }
    return self;
}

+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret {
    [Parse setApplicationId:appId clientKey:appSecret];
    [PFFacebookUtils initializeFacebook];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    [GSSession activeSession].firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", kFireBaseBaseURL, appName]];
}

+ (BOOL)isAuthenticated {
    return ([[GSSession activeSession] currentUser] != nil);
}

- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSessionDelegate>)delegate {
    self.delegate = delegate;
    
    CPLogInViewController *logInController = [[CPLogInViewController alloc] init];
    logInController.delegate = self;
    
    // For next, we should allocate new Sign Up View Controller to be able to customize the UI
    logInController.signUpController.delegate = self;
    
    // We should check Facebook permissions for this
    NSArray *permissions = [NSArray arrayWithObjects:@"user_about_me", @"user_photos", @"publish_stream", @"offline_access", @"email", @"user_location", nil];
    [logInController setFacebookPermissions:permissions];
    [logInController setFields:PFLogInFieldsUsernameAndPassword
                             | PFLogInFieldsFacebook
                             | PFLogInFieldsSignUpButton
                             | PFLogInFieldsDismissButton];
    [viewController presentModalViewController:logInController animated:YES];
}

#pragma mark - Sign Up View Controller Delegate Methods

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self initEssentialDataBlock:^(BOOL succeed, NSError *error) {
            [self setUserInitialApp];
            [self initOrUpdateGSUser];
            [self.delegate didLoginSucceeded]; // Dismiss the PFSignUpViewController
        }];
    }
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    DLog(@"Failed to sign up... %@", error);
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
    }
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    DLog(@"User dismissed the signUpViewController");
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self setUserInitialApp];
        
        if ([PFFacebookUtils isLinkedWithUser:user]) {
            [self linkFacebookDataBlock:^(BOOL succeed, NSError *error) {
                [self initOrUpdateGSUser];
                [self.delegate didLoginSucceeded];
            }];
        } else {
            [self initEssentialDataBlock:^(BOOL succeed, NSError *error) {
                [self initOrUpdateGSUser];
                [self.delegate didLoginSucceeded];
            }];
        }
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
    }
}

- (void)updateUserInfoFromSmartboardAPIWithBlock:(GSResultBlock)block {
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self linkFacebookDataBlock:^(BOOL succeed, NSError *error) {
            [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
                block(YES, error);
            }];
        }];
    } else {
        [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
            block(YES, error);
        }];
    }
}

- (void)logOutWithBlock:(GSResultBlock)block {
    [[PFUser currentUser] setObject:[NSDate date] forKey:@"last_log_in"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFUser logOut];
        self.currentUser = nil;
        block(succeeded, error);
    }];
}

- (void)addObserver:(id<GSSessionDelegate>)delegate {
    self.delegate = delegate;
    
    [[self getMyBaseFirebase] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self receiveData:snapshot];
    }];
    
    [[self getMyBaseFirebase] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self receiveData:snapshot];
    }];
    
}

- (void)receiveData:(FDataSnapshot *)snapshot {
    for (FDataSnapshot *childSnapshot in snapshot.children) {
        NSString *senderUID = childSnapshot.value[@"sender"];
        NSString *receiverUID = childSnapshot.value[@"receiver"];
        NSString *messageType = childSnapshot.value[@"type"];
        NSObject *messageContent = childSnapshot.value[@"content"];
        NSString *messageTime = childSnapshot.value[@"time"];
        NSObject *messageData = nil;
        
        if (![receiverUID isEqualToString:self.currentUser.uid]) {
            DLog(@"This update from %@ to %@ is not for me: %@", senderUID, receiverUID, self.currentUser.uid);
            return;
        }
        
        if ([messageType isEqualToString:@"string"]) {
            messageData = messageContent;
            
        } else if ([messageType isEqualToString:@"image"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithStatus:@"Receiving image"];
                
                dispatch_async(dispatch_get_current_queue(), ^{
                    NSObject *messageData = nil;
                    if ([messageContent isKindOfClass:[NSArray class]]) {
                        NSMutableString *messageString = [NSMutableString new];
                        for (int i = 0; i < [((NSArray *) messageContent) count]; i++) {
                            [messageString appendString:[((NSArray *) messageContent) objectAtIndex:i]];
                        }
                        NSData *imageData = [NSData dataFromBase64String:messageString];
                        DLog(@"Receive image Size: %fMB", (float)[imageData length]/(float)(1024*1024));
                        messageData = [UIImage imageWithData:imageData];
                        
                    } else {
                        NSData *imageData = [NSData dataFromBase64String:((NSString *)messageContent)];
                        DLog(@"Receive image Size: %fMB", (float)[imageData length]/(float)(1024*1024));
                        messageData = [UIImage imageWithData:imageData];
                    }
                    
                    [SVProgressHUD dismissWithSuccess:@"Image received"];
                    if (messageData) {
                        if (self.delegate
                            && [((id)self.delegate) respondsToSelector:@selector(didReceiveMessageFrom:content:time:)]) {
                            [self.delegate didReceiveMessageFrom:senderUID content:messageData time:messageTime];
                        }
                    }
                });
            });
        }
        
        if (messageData && [receiverUID isEqualToString:self.currentUser.uid]) {
            if (self.delegate
                && [((id)self.delegate) respondsToSelector:@selector(didReceiveMessageFrom:content:time:)]) {
                [self.delegate didReceiveMessageFrom:senderUID content:messageData time:messageTime];
            }
        }
    }
}

- (void)sendMessage:(NSObject *)messageContent toUser:(GSUser *)user {
    if ([messageContent isKindOfClass:[NSString class]]) {
        NSString *messageType = @"string";
        NSString *messageData = (NSString *)messageContent;
        NSString *messageTime = [GSUtils getCurrentTime];
        [[self generateFirebaseFor:user atTime:messageTime] setValue:@{@"sender"   : self.currentUser.uid,
                                                                       @"receiver" : user.uid,
                                                                       @"type"     : messageType,
                                                                       @"content"  : messageData,
                                                                       @"time"     : messageTime}];
        
    } else if ([messageContent isKindOfClass:[UIImage class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Sending image"];
            
            dispatch_async(dispatch_get_current_queue(), ^{
                NSData *imageData = UIImageJPEGRepresentation(((UIImage *) messageContent), 0.5);
                DLog(@"Sent image Size: %fMB", (float)[imageData length]/(float)(1024*1024));
                NSString *messageType = @"image";
                NSString *messageString = [imageData base64EncodedString];
                NSString *messageTime = [GSUtils getCurrentTime];
                NSObject *messageData = @"";
                
                int numOfElement = round((float)[messageString length]/(float)kMaxSizeFirebaseString);
                if (numOfElement > 1) { // More than 1 element
                    NSMutableArray *elementArray = [NSMutableArray arrayWithCapacity:numOfElement];
                    for (int i = 0; i < numOfElement; i++) {
                        int location = kMaxSizeFirebaseString*i;
                        int length = (kMaxSizeFirebaseString > ([messageString length]-location)
                                      ? ([messageString length]-location)
                                      : kMaxSizeFirebaseString);
                        NSString *element = [messageString substringWithRange:NSMakeRange(location, length)];
                        [elementArray addObject:element];
                    }                    
                    messageData = elementArray;
                    
                } else {
                    messageData = messageString;
                }
                
                
                [[self generateFirebaseFor:user atTime:messageTime] setValue:@{@"sender"   : self.currentUser.uid,
                                                                               @"receiver" : user.uid,
                                                                               @"type"     : messageType,
                                                                               @"content"  : messageData,
                                                                               @"time"     : messageTime}
                                                         withCompletionBlock:^(NSError *error) {
                                                             [SVProgressHUD dismissWithSuccess:@"Image sent"];
                                                                               }];
            });
        });
    }
}

- (void)removeMessageFromSender:(GSUser *)user atTime:(NSString *)messageTime {
    Firebase *myBaseFirebase = [self getMyBaseFirebase];
    Firebase *senderFirebaseInMyFirebase = [myBaseFirebase childByAppendingPath:[NSString stringWithFormat:@"Sender_%@", user.uid]];
    NSString *timeFirebaseName = [NSString stringWithFormat:@"%@_%@", user.username, messageTime];
    Firebase *timeFirebase = [senderFirebaseInMyFirebase childByAppendingPath:timeFirebaseName];
    DLog(@"Remove fire base: %@", [timeFirebase name]);
    [timeFirebase removeValue];
}

- (void)getNearbyUserWithBlock:(GSArrayResultBlock)block {
    PFGeoPoint *currentLocation = [[PFUser currentUser] objectForKey:@"location"];
    
    if (currentLocation != nil) {
        // Query for locations near mine
        PFQuery *query = [PFUser query];
        [query whereKey:@"location"
           nearGeoPoint:currentLocation];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSMutableArray *nearByUserExceptMe = [[NSMutableArray alloc] init];
                for (PFUser *user in objects) {
                    if (![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        // Also update last seen if never seen
                        if (![user objectForKey:@"last_log_in"]) {
                            [user setObject:user.updatedAt forKey:@"last_log_in"];
                        }
                        
                        GSUser *gsUser = [[GSUser alloc] initWithPFUser:user];
                        [nearByUserExceptMe addObject:gsUser];
                    }
                }
                DLog(@"Number of nearby users: %d", [nearByUserExceptMe count]);
                block(nearByUserExceptMe, error);
            }
        }];
    } else {
        [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
            [self getNearbyUserWithBlock:block];
        }];
    }
}

- (NSString *)currentUserName {
    if ([GSSession isAuthenticated]) {
        if (self.currentUser.fullname != nil) {
            return self.currentUser.fullname;
        } else {
            return self.currentUser.username;
        }
        
    } else {
        return @"";
    }
}

- (void)queryClass:(NSString *)classname
             where:(NSArray *)queryCondition
             block:(GSArrayResultBlock)block {
    
    PFQuery *query = [PFQuery queryWithClassName:classname];
    for (int i = 0; i < [queryCondition count]-1; i += 2) {
        NSString *key = [queryCondition objectAtIndex:i];
        NSString *value = [queryCondition objectAtIndex:i+1];
        [query whereKey:key equalTo:value];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSMutableArray *result = [NSMutableArray new];
            for (PFObject *pfObject in objects) {
                GSObject *object = [[GSObject alloc] initWithPFObject:pfObject];
                [result addObject:object];
            }
            
            block(result, error);            
    }];
}

- (void)updateClass:(NSString *)classname
               with:(NSArray *)valueToSet
              where:(NSArray *)queryCondition
              block:(GSResultBlock)block {
    
    PFQuery *query = [PFQuery queryWithClassName:classname];
    for (int i = 0; i < [queryCondition count]-1; i += 2) {
        NSString *key = [queryCondition objectAtIndex:i];
        NSString *value = [queryCondition objectAtIndex:i+1];
        [query whereKey:key equalTo:value];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) { // Empty, so just create it
            PFObject *object = [PFObject objectWithClassName:classname];
            for (int i = 0; i < [queryCondition count]-1; i += 2) {
                NSString *key = [queryCondition objectAtIndex:i];
                NSString *value = [queryCondition objectAtIndex:i+1];
                [object setObject:value forKey:key];
                
                for (int j = 0; j < [valueToSet count]-1; j += 2) {
                    NSString *key = [valueToSet objectAtIndex:j];
                    NSString *value = [valueToSet objectAtIndex:j+1];
                    [object setObject:value forKey:key];
                }
            }
            
            [object saveInBackground];
            
        } else {
            for (PFObject *object in objects) {
                for (int j = 0; j < [valueToSet count]-1; j += 2) {
                    NSString *key = [valueToSet objectAtIndex:j];
                    NSString *value = [valueToSet objectAtIndex:j+1];
                    [object setObject:value forKey:key];
                }
                [object saveInBackground];
            }
        }
        
        block(YES, error);
    }];
}

#pragma mark - INTERFACE
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.currentUser updateWithPFUser:[PFUser currentUser]
                                 block:^(BOOL succeed, NSError *error) {}];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.currentUser updateWithPFUser:[PFUser currentUser]
                                 block:^(BOOL succeed, NSError *error) {}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.currentUser updateWithPFUser:[PFUser currentUser]
                                 block:^(BOOL succeed, NSError *error) {}];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.currentUser updateWithPFUser:[PFUser currentUser]
                                 block:^(BOOL succeed, NSError *error) {}];
}

- (void)linkFacebookDataBlock:(GSResultBlock)block {
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *username = userData[@"username"];
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            [[PFUser currentUser] setObject:name forKey:@"fullname"];
            [[PFUser currentUser] setObject:pictureURL forKey:@"avatar_url"];
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"facebook_linked"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebook_id"];
            [[PFUser currentUser] setObject:username forKey:@"facebook_screen_name"];
            [[PFUser currentUser] saveInBackground];
        }
        block(YES, error);
    }];
}

- (void)initEssentialDataBlock:(GSResultBlock)block {
    BOOL haveUpdate = NO;
    if (![[PFUser currentUser] objectForKey:@"fullname"]) {
        [[PFUser currentUser] setObject:[[PFUser currentUser] username] forKey:@"fullname"];
        haveUpdate = YES;
    }
    
    if (haveUpdate) {
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            block(succeeded, error);
        }];
    } else {
        block(NO, nil);
    }
}

- (void)setUserInitialApp {
    if (![[PFUser currentUser] objectForKey:@"initial_app_name"]) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        [[PFUser currentUser] setObject:appName forKey:@"initial_app_name"];
        [[PFUser currentUser] saveInBackground];
    }
}

- (void)initOrUpdateGSUser {
    if (self.currentUser == nil) {
        self.currentUser = [[GSUser alloc] initWithPFUser:[PFUser currentUser]];
    } else {
        [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
    }
}

- (void)updateUserDataWithBlock:(GSResultBlock)block {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
        [[PFUser currentUser] setObject:[NSDate date] forKey:@"last_log_in"];
        if (![[PFUser currentUser] objectForKey:@"fullname"]) {
            [[PFUser currentUser] setObject:[[PFUser currentUser] username] forKey:@"fullname"];
        }
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self initOrUpdateGSUser];
            block(YES, error);
        }];
    }];
}

- (Firebase *)getMyBaseFirebase {
    return [self.firebase childByAppendingPath:[NSString stringWithFormat:@"User_%@", self.currentUser.uid]];
}

- (Firebase *)generateFirebaseFor:(GSUser *)user atTime:(NSString *)time {
    Firebase *receiverBaseFirebase = [self.firebase childByAppendingPath:[NSString stringWithFormat:@"User_%@", user.uid]];
    Firebase *senderFirebaseInReceiverBaseFirebase = [receiverBaseFirebase childByAppendingPath:[NSString stringWithFormat:@"Sender_%@", self.currentUser.uid]];
    NSString *timeFirebaseName = [NSString stringWithFormat:@"%@_%@", self.currentUser.username, time];
    Firebase *timeFirebase = [senderFirebaseInReceiverBaseFirebase childByAppendingPath:timeFirebaseName];
    DLog(@"Create fire base: %@", [timeFirebase name]);
    return timeFirebase;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (activeSession == nil) {
            activeSession = [super allocWithZone:zone];
            return activeSession;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
