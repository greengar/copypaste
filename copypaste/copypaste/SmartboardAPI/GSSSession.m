//
//  GSSSession.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSSession.h"
#import "GSSParseQueryHelper.h"
#import "NSData+Base64.h"
#import "SVProgressHUD.h"
#import "GSObject.h"

#define kFireBaseBaseURL @"https://gg.firebaseio.com/"
#define kMaxSizeFirebaseString 5000000 //10485760

static GSSSession *activeSession = nil;

@interface GSSSession()
- (Firebase *)getMyBaseFirebase;
- (Firebase *)generateFirebaseFor:(GSSUser *)user atTime:(NSString *)time;
@property (nonatomic, retain) Firebase *firebase;
@end

@implementation GSSSession
@synthesize firebase = _firebase;
@synthesize delegate = _delegate;
@synthesize currentUser = _currentUser;

+ (GSSSession *)activeSession {
    static GSSSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [GSSSession new]; });
    return activeSession;
}

- (id)init {
    if (self = [super init]) {
        if ([PFUser currentUser]) {
            if (self.currentUser == nil) {
                self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
            } else {
                [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
            }
        }
    }
    return self;
}

+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret {
    [Parse setApplicationId:appId clientKey:appSecret];
    [PFFacebookUtils initializeFacebook];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    [GSSSession activeSession].firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@%@", kFireBaseBaseURL, appName]];
}

+ (BOOL)isAuthenticated {
    return ([[GSSSession activeSession] currentUser] != nil);
}

- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate {
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

- (void)logOut {
    [PFUser logOut];
    self.currentUser = nil;
}

- (void)addObserver:(id<GSSSessionDelegate>)delegate {
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
                        if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(didReceiveMessageFrom:content:time:)]) {
                            [self.delegate didReceiveMessageFrom:senderUID content:messageData time:messageTime];
                        }
                    }
                });
            });
        }
        
        if (messageData && [receiverUID isEqualToString:self.currentUser.uid]) {
            if (self.delegate && [((id)self.delegate) respondsToSelector:@selector(didReceiveMessageFrom:content:time:)]) {
                [self.delegate didReceiveMessageFrom:senderUID content:messageData time:messageTime];
            }
        }
    }
}

- (void)sendMessage:(NSObject *)messageContent toUser:(GSSUser *)user {
    if ([messageContent isKindOfClass:[NSString class]]) {
        NSString *messageType = @"string";
        NSString *messageData = (NSString *)messageContent;
        NSString *messageTime = [GSSUtils getCurrentTime];
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
                NSString *messageTime = [GSSUtils getCurrentTime];
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

- (void)removeMessageFromSender:(GSSUser *)user atTime:(NSString *)messageTime {
    Firebase *myBaseFirebase = [self getMyBaseFirebase];
    Firebase *senderFirebaseInMyFirebase = [myBaseFirebase childByAppendingPath:[NSString stringWithFormat:@"Sender_%@", user.uid]];
    NSString *timeFirebaseName = [NSString stringWithFormat:@"%@_%@", user.username, messageTime];
    Firebase *timeFirebase = [senderFirebaseInMyFirebase childByAppendingPath:timeFirebaseName];
    DLog(@"Remove fire base: %@", [timeFirebase name]);
    [timeFirebase removeValue];
}

- (void)getNearbyUserWithDelegate:(id<GSSSessionDelegate>)delegate {
    self.delegate = delegate;
    PFGeoPoint *currentLocation = [[PFUser currentUser] objectForKey:@"location"];
    
    if (currentLocation != nil) {
        // Query for locations near mine
        PFQuery *query = [PFUser query];
        [query setLimit:10];
        [query whereKey:@"location"
           nearGeoPoint:currentLocation];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                NSMutableArray *nearByUserExceptMe = [[NSMutableArray alloc] init];
                for (PFUser *user in objects) {
                    if (![[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        GSSUser *gsUser = [[GSSUser alloc] initWithPFUser:user];
                        [nearByUserExceptMe addObject:gsUser];
                    }
                }
                
                DLog(@"Number of nearby users: %d", [nearByUserExceptMe count]);
                if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didGetNearbyUserSucceeded:)]) {
                    [self.delegate didGetNearbyUserSucceeded:nearByUserExceptMe];
                }
            }
        }];
    } else {
        [self getMyLocation];
    }
}

- (void)getMyLocation {
    // Update my location
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                DLog(@" My location: %@", [[PFUser currentUser] objectForKey:@"location"]);
                
                [self getNearbyUserWithDelegate:self.delegate];
            } else {
                if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didGetNearbyUserFailed:)]) {
                    [self.delegate didGetNearbyUserFailed:error];
                }
            }
        }];
    }];
}

- (NSString *)currentUserName {
    if ([GSSSession isAuthenticated]) {
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
             block:(GSArrayResultBlock)block
{
//    self.delegate = delegate;
    
    PFQuery *query = [PFQuery queryWithClassName:classname];
    for (int i = 0; i < [queryCondition count]-1; i += 2) {
        NSString *key = [queryCondition objectAtIndex:i];
        NSString *value = [queryCondition objectAtIndex:i+1];
        [query whereKey:key equalTo:value];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (error) {
//            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didQueryFailed:)]) {
//                [self.delegate didQueryFailed:error];
//            }
//        } else {
            NSMutableArray *result = [NSMutableArray new];
            for (PFObject *pfObject in objects)
            {
                GSObject *object = [[GSObject alloc] initWithPFObject:pfObject];
                [result addObject:object];
            }
            
            block(result, error);
            
//            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didQueryForKey:didFinish:)]) {
//                [self.delegate didQueryForKey:resultKey didFinish:result];
//            }
            
//            if (forceSave && [objects count] == 0) {
//                PFObject *object = [PFObject objectWithClassName:classname];
//                for (int i = 0; i < [queryCondition count]-1; i += 2) {
//                    NSString *key = [queryCondition objectAtIndex:i];
//                    NSString *value = [queryCondition objectAtIndex:i+1];
//                    [object setValue:value forKey:key];
//                }
//                [object saveInBackground];
//                
//            } else {
//                NSMutableArray *result = [NSMutableArray new];
//                for (PFObject *object in objects) {
//                    for (NSString *key in resultKey) {
//                        NSObject *value = [object objectForKey:key];
//                        [object allKeys]
//                        
//                        NSMutableDictionary *valueDict = [NSMutableDictionary new];
//                        [valueDict setObject:value forKey:key];
//                        
//                        [result addObject:[object objectId]];
//                        [result addObject:valueDict];
//                    }
//                }
//            
//            }
//        }
    }];
}

- (void)updateClass:(NSString *)classname
               with:(NSArray *)valueToSet
              where:(NSArray *)queryCondition
           delegate:(id<GSSSessionDelegate>)delegate {
    self.delegate = delegate;
    
    PFQuery *query = [PFQuery queryWithClassName:classname];
    for (int i = 0; i < [queryCondition count]-1; i += 2) {
        NSString *key = [queryCondition objectAtIndex:i];
        NSString *value = [queryCondition objectAtIndex:i+1];
        [query whereKey:key equalTo:value];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didUpdateClassFailed:)]) {
                [self.delegate didUpdateClassFailed:error];
                self.delegate = nil;
            }
        } else {
            if ([objects count] == 0) { // Empty, so just create it
                PFObject *object = [PFObject objectWithClassName:classname];
                for (int i = 0; i < [queryCondition count]-1; i += 2) {
                    NSString *key = [queryCondition objectAtIndex:i];
                    NSString *value = [queryCondition objectAtIndex:i+1];
                    [object setValue:value forKey:key];
                    
                    for (int j = 0; j < [valueToSet count]-1; j += 2) {
                        NSString *key = [valueToSet objectAtIndex:j];
                        NSString *value = [valueToSet objectAtIndex:j+1];
                        [object setValue:value forKey:key];
                    }
                }
                
                [object saveInBackground];
                
            } else {
                for (PFObject *object in objects) {
                    for (int j = 0; j < [valueToSet count]-1; j += 2) {
                        NSString *key = [valueToSet objectAtIndex:j];
                        NSString *value = [valueToSet objectAtIndex:j+1];
                        [object setValue:value forKey:key];
                    }
                    [object saveInBackground];
                }
            }
            
            if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didUpdateClassSucceeded)]) {
                [self.delegate didUpdateClassSucceeded];
                self.delegate = nil;
            }
        }
    }];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {        
        if ([PFFacebookUtils isLinkedWithUser:user]) {
            // Create request for user's Facebook data
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    NSString *facebookID = userData[@"id"];
                    NSString *name = userData[@"name"];
                    NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                    
                    [[PFUser currentUser] setObject:name forKey:@"fullname"];
                    [[PFUser currentUser] setObject:pictureURL forKey:@"avatar_url"];
                    if (![[PFUser currentUser] objectForKey:@"initial_app_name"]) {
                        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                        [[PFUser currentUser] setObject:appName forKey:@"initial_app_name"];
                    }
                    [[PFUser currentUser] saveInBackground];
                    
                    // Parse again with new data
                    if (self.currentUser == nil) {
                        self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
                    } else {
                        [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
                    }
                    
                    [self.delegate didLoginSucceeded];
                    self.delegate = nil;
                }
            }];
        } else {
            if (![[PFUser currentUser] objectForKey:@"initial_app_name"]) {
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                [[PFUser currentUser] setObject:appName forKey:@"initial_app_name"];
            }
            [[PFUser currentUser] saveInBackground];
            
            if (self.currentUser == nil) {
                self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
            } else {
                [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
            }
            [self.delegate didLoginSucceeded];
            self.delegate = nil;
        }
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
        self.delegate = nil;
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [[PFUser currentUser] setObject:user.username forKey:@"fullname"];
        if (![[PFUser currentUser] objectForKey:@"initial_app_name"]) {
            NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            [[PFUser currentUser] setObject:appName forKey:@"initial_app_name"];
        }
        [[PFUser currentUser] saveInBackground];
        
        if (self.currentUser == nil) {
            self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
        } else {
            [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
        }
        
        [self.delegate didLoginSucceeded];
        self.delegate = nil;
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
        self.delegate = nil;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (Firebase *)getMyBaseFirebase {
    return [self.firebase childByAppendingPath:[NSString stringWithFormat:@"User_%@", self.currentUser.uid]];
}

- (Firebase *)generateFirebaseFor:(GSSUser *)user atTime:(NSString *)time {
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
