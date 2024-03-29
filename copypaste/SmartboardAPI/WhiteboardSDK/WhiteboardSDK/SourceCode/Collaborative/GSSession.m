//
//  GSSSession.m
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSession.h"

#import "GSSignUpLogInViewController.h"
#import "GSParseQueryHelper.h"
#import "NSData+GSBase64.h"
#import "GSSVProgressHUD.h"
#import "GSObject.h"

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>

#define kFireBaseBaseURL @"https://gg.firebaseio.com/"

#define kSenderUIDKey @"sender"
#define kSenderUsernameKey @"sender_name"
#define kSenderAvatarURLKey @"sender_avatar"
#define kSenderLongitudeKey @"sender_long"
#define kSenderLatitudeKey @"sender_lat"
#define kReceiverUIDKey @"receiver"
#define kMessageTypeKey @"type"
#define kMessageTimeKey @"time"
#define kMessageContentKey @"content"

static GSSession *activeSession = nil;

@interface GSSession() <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
- (void)linkFacebookDataBlock:(GSResultBlock)block;
- (void)initEssentialDataBlock:(GSResultBlock)block;
- (void)setUserInitialApp;
- (void)initOrUpdateGSUser;
- (void)updateUserDataWithBlock:(GSResultBlock)block;
- (void)goOnline:(BOOL)online;
- (Firebase *)getMyBaseFirebase;
- (Firebase *)generateFirebaseForUser:(GSUser *)user atTime:(NSString *)time;
- (Firebase *)generateFirebaseForRoom:(GSRoom *)room;
@property (nonatomic, strong) Firebase *firebase;
@property (nonatomic, strong) NSString *mySecretId;
@end

@implementation GSSession
@synthesize firebase = _firebase;
@synthesize mySecretId = _mySecretId;
@synthesize currentUser = _currentUser;
@synthesize delegate = _delegate;
@synthesize msgDelegate = _msgDelegate;
@synthesize roomDelegate = _roomDelegate;
@synthesize authenticationController = _authenticationController;

+ (GSSession *)activeSession {
    static GSSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [GSSession new]; });
    return activeSession;
}

+ (GSUser *)currentUser {
    return [[GSSession activeSession] currentUser];
}

- (NSString *)currentUserName {
    if ([GSSession isAuthenticated]) {
        return [self.currentUser displayName];
        
    } else {
        return @"";
    }
}

- (id)init {
    if (self = [super init]) {
        if ([PFUser currentUser]) {
            [self goOnline:YES];
            [self initOrUpdateGSUser];
        }
    }
    return self;
}

+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret {
    [Parse setApplicationId:appId clientKey:appSecret];
    [PFFacebookUtils initializeFacebook];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *firebaseURL = [[NSString alloc] initWithFormat:@"%@%@", kFireBaseBaseURL, appName];
    [GSSession activeSession].firebase = [[Firebase alloc] initWithUrl:firebaseURL];
}

+ (BOOL)isAuthenticated {
    return ([PFUser currentUser] ? YES : NO);
    
    // why does this not work?:
    return ([[GSSession activeSession] currentUser] != nil);
}

#pragma mark - Authentication

- (void)authenticateFromViewController:(UIViewController<GSSessionDelegate> *)viewController animated:(BOOL)animated
{
    self.delegate = viewController;
    self.authenticationController = viewController;
    
    GSSignUpLogInViewController *vc = [[GSSignUpLogInViewController alloc] init];
    [viewController presentViewController:vc animated:animated completion:NULL];
    
    // TODO: facebook permissions
//    [logInController setFacebookPermissions:@[@"user_about_me", @"user_photos", @"publish_stream", @"offline_access", @"email", @"user_location"]];
}

- (void)updateUserInfoFromSmartboardAPIWithBlock:(GSResultBlock)block {
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self linkFacebookDataBlock:^(BOOL succeed, NSError *error) {
            [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
                if (block) { block(YES, error); }
             
            }];
        }];
    } else {
        [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
            if (block) { block(YES, error); }
        }];
    }
}

- (void)logOutWithBlock:(GSResultBlock)block {
    [[PFUser currentUser] setObject:[NSDate date] forKey:@"last_log_in"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // TODO: app can freeze here :(
        [PFUser logOut];
        
        self.currentUser = nil;
        if (block) { block(succeeded, error); }
    }];
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
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didFinishAuthentication:)]) {
        [self initEssentialDataBlock:^(BOOL succeed, NSError *error) {
            [self goOnline:YES];
            [self setUserInitialApp];
            [self initOrUpdateGSUser];
            [self.delegate didFinishAuthentication:error];
            
            if (!error) {
                [self.authenticationController dismissViewControllerAnimated:YES
                                                                  completion:NULL];
            }
        }];
    }
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    DLog(@"Failed to sign up... %@", error);
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didFinishAuthentication:)]) {
        [self.delegate didFinishAuthentication:error];
    }
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    DLog(@"User dismissed the signUpViewController");
}

#pragma mark - Log In View Controller Delegate Methods
// Sent to the delegate to determine whether the log in request should be submitted to the server.
// Note that this method is NOT called when Twitter or Facebook login is used.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didFinishAuthentication:)]) {
        [self setUserInitialApp]; // set initial_app_name
        
        if ([PFFacebookUtils isLinkedWithUser:user]) {
            [self linkFacebookDataBlock:^(BOOL succeed, NSError *error) {
                [self goOnline:YES];
                [self initOrUpdateGSUser];
                [self.delegate didFinishAuthentication:error];
                
                if (!error) {
                    [self.authenticationController dismissViewControllerAnimated:YES
                                                                      completion:NULL];
                }
            }];
        } else {
            [self initEssentialDataBlock:^(BOOL succeed, NSError *error) {
                [self goOnline:YES];
                [self initOrUpdateGSUser];
                [self.delegate didFinishAuthentication:error];
                
                if (!error) {
                    [self.authenticationController dismissViewControllerAnimated:YES
                                                                      completion:NULL];
                }
            }];
        }
    }
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didFinishAuthentication:)]) {
        [self.delegate didFinishAuthentication:error];
    }
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    DLog(@"User dismissed the logInViewController");
}

#pragma mark - Peer-to-Peer Messages
- (void)registerMessageReceiver:(id<GSMessageDelegate>)delegate {
    self.msgDelegate = delegate;
    
    [[self getMyBaseFirebase] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self receiveData:snapshot];
    }];
    
    [[self getMyBaseFirebase] observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [self receiveData:snapshot];
    }];
    
}

- (void)receiveData:(FDataSnapshot *)snapshot {
    for (FDataSnapshot *childSnapshot in snapshot.children) {
        NSMutableDictionary *messageDict = [NSMutableDictionary new];
        for (FDataSnapshot *child in childSnapshot.children) {
            [messageDict setObject:child.value forKey:child.name];
        }
        [messageDict setObject:childSnapshot.name forKey:@"uid"];
        
        if (self.msgDelegate && [((id)self.msgDelegate) respondsToSelector:@selector(didReceiveMessage:)]) {
            [self.msgDelegate didReceiveMessage:messageDict];
        }
    }
}

- (void)sendData:(NSDictionary *)dictionary toUser:(GSUser *)user withBlock:(GSResultBlock)block {
    [[self generateFirebaseForUser:user
                            atTime:[GSUtils getCurrentTime]]
                          setValue:dictionary
               withCompletionBlock:^(NSError *error) {
                   if (block) { block(YES, error); }
    }];
}

- (void)removeMessageFromSender:(GSUser *)user atTime:(NSString *)messageTime {
    Firebase *myBaseFirebase = [self getMyBaseFirebase];
    Firebase *senderFirebaseInMyFirebase = [myBaseFirebase childByAppendingPath:[NSString stringWithFormat:@"Sender_%@", user.uid]];
    NSString *timeFirebaseName = [NSString stringWithFormat:@"%@_%@", user.username, messageTime];
    Firebase *timeFirebase = [senderFirebaseInMyFirebase childByAppendingPath:timeFirebaseName];
    DLog(@"Remove fire base: %@", [timeFirebase name]);
    [timeFirebase removeValue];
}

#pragma mark - Request Users
- (void)getUsersByEmail:(NSString *)email block:(GSArrayResultBlock)block {
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            NSMutableArray *users = [NSMutableArray new];
            for (PFUser *pfUser in objects) {
                GSUser *gsUser = [[GSUser alloc] initWithPFUser:pfUser];
                [users addObject:gsUser];
            }
            if (block) { block(users, error); }
        } else {
            if (block) { block(objects, error); }
        }
    }];
}

- (void)getNearbyUserWithBlock:(GSArrayResultBlock)block {
    PFGeoPoint *currentLocation = [[PFUser currentUser] objectForKey:@"location"];
    
    if (currentLocation != nil) {
        // Query for locations near mine
        PFQuery *query = [PFUser query];
        [query setLimit:30];
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
                        
                        GSUser *gsUser = [[GSUser alloc] initWithPFUser:user cacheAvatar:NO];
                        [nearByUserExceptMe addObject:gsUser];
                    }
                }
                DLog(@"Number of nearby users: %d", [nearByUserExceptMe count]);
                if (block) { block(nearByUserExceptMe, error); }
            }
        }];
    } else {
        [self updateUserDataWithBlock:^(BOOL succeed, NSError *error) {
            [self getNearbyUserWithBlock:block];
        }];
    }
}

#pragma mark - Request Rooms
- (void)registerRoomDataChanged:(GSRoom *)room
                           type:(GSEventType)eventType
                      withBlock:(GSSingleResultBlock)block {
    room.isListening = YES;
    [[self generateFirebaseForRoom:room] observeEventType:[self firebaseEventFromGSEvent:eventType]
                                                withBlock:^(FDataSnapshot *snapshot) {
        if (!room.isListening) {
            [self unregisterRoomDataChanged:room];
        } else {
            if (snapshot) {
                if ([[snapshot value] isKindOfClass:[NSArray class]]) {
                    NSMutableDictionary *data = [NSMutableDictionary new];
                    for (FDataSnapshot *child in [snapshot children]) {
                        [data setObject:[child value] forKey:[child name]];
                    }
                    if (block) { block(@{[snapshot name]: data}, nil); }
                } else {
                    if (block) { block(@{[snapshot name]: [snapshot value]}, nil); }
                }
            } else {
                if (block) { block(nil, nil); }
            }
        }
    }];
}

- (void)registerRoomDataChanged:(GSRoom *)room
                          atURL:(NSString *)urlString
                           type:(GSEventType)eventType
                      withBlock:(GSSingleResultBlock)block {
    room.isListening = YES;
    NSArray *parseURL = [urlString componentsSeparatedByString:@"/"];
    Firebase *firebase = [self generateFirebaseForRoom:room];
    for (int i = 0; i < [parseURL count]; i++) {
        firebase = [firebase childByAppendingPath:[parseURL objectAtIndex:i]];
    }
    [firebase observeEventType:[self firebaseEventFromGSEvent:eventType]
                     withBlock:^(FDataSnapshot *snapshot) {
                         if (!room.isListening) {
                             [self unregisterRoomDataChanged:room atURL:urlString];
                         } else {
                             NSDictionary *dataChangedAtURL = [snapshot value];
                             if (block) { block(dataChangedAtURL, nil); }
                         }
                     }];
    firebase = nil;
}

- (void)unregisterRoomDataChanged:(GSRoom *)room {
    room.isListening = NO;
    [[self generateFirebaseForRoom:room] removeAllObservers];
}

- (void)unregisterRoomDataChanged:(GSRoom *)room atURL:(NSString *)urlString {
    room.isListening = NO;
    NSArray *parseURL = [urlString componentsSeparatedByString:@"/"];
    Firebase *firebase = [self generateFirebaseForRoom:room];
    for (int i = 0; i < [parseURL count]; i++) {
        firebase = [firebase childByAppendingPath:[parseURL objectAtIndex:i]];
    }
    [firebase removeAllObservers];
}

- (void)createRoomWithName:(NSString *)roomName
                 isPrivate:(BOOL)isPrivate
               codeToEnter:(NSString *)codeToEnter
                 shareWith:(NSArray *)sharedEmails
                     block:(GSSingleResultBlock)block {
    // Save to Parse
    GSRoom *room = [[GSRoom alloc] initWithName:roomName
                                        ownerId:[[GSSession currentUser] uid]
                                      isPrivate:isPrivate
                                    codeToEnter:codeToEnter
                                   sharedEmails:sharedEmails];
    [room saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
        if (block) { block(room, error); }
    }];
    
    // Save to Firebase
}

- (void)deleteRoom:(GSRoom *)room block:(GSResultBlock)block {
    [room deleteInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
        if (succeed) {
            [[self generateFirebaseForRoom:room] removeValue];
        }
        if (block) { block (succeed, error); }
    }];
}

- (void)getAllPublicRoomWithBlock:(GSArrayResultBlock)block {
    PFQuery *query = [PFQuery queryWithClassName:[GSRoom classname]];
    [query whereKey:@"private" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            NSMutableArray *rooms = [NSMutableArray new];
            for (PFObject *pfObject in objects) {
                GSRoom *gsRoom = [[GSRoom alloc] initWithPFObject:pfObject];
                [rooms addObject:gsRoom];
            }
            if (block) { block(rooms, error); }
        } else {
            if (block) { block(objects, error); }
        }
    }];
}

- (void)getRoomShareWithMeWithBlock:(GSArrayResultBlock)block {
    PFQuery *query = [PFQuery queryWithClassName:[GSRoom classname]];
    [query whereKey:@"shared_emails"
           containsAllObjectsInArray:[NSArray arrayWithObjects:[[GSSession currentUser] email], nil]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            NSMutableArray *rooms = [NSMutableArray new];
            for (PFObject *pfObject in objects) {
                GSRoom *gsRoom = [[GSRoom alloc] initWithPFObject:pfObject];
                [rooms addObject:gsRoom];
            }
            if (block) { block(rooms, error); }
        } else {
            if (block) { block(objects, error); }
        }
    }];
}

- (void)getRoomWithCode:(NSString *)code block:(GSSingleResultBlock)block {
    PFQuery *query = [PFQuery queryWithClassName:[GSRoom classname]];
    [query whereKey:@"code" equalTo:code];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            PFObject *pfObject = [objects objectAtIndex:0];
            GSRoom *gsRoom = [[GSRoom alloc] initWithPFObject:pfObject];
            if (block) { block(gsRoom, error); }
        } else {
            if (block) { block(nil, error); }
        }
    }];
}

#pragma mark - Update Rooms
- (void)sendRoomData:(GSRoom *)room {
    [[self generateFirebaseForRoom:room] setValue:room.data];
}

- (void)removeRoomData:(GSRoom *)room {
    [[self generateFirebaseForRoom:room] removeValue];
}

- (void)sendData:(NSDictionary *)dict ofRoom:(GSRoom *)room atURL:(NSString *)urlString {
    Firebase *firebase = [[self generateFirebaseForRoom:room] childByAppendingPath:urlString];
    [firebase setValue:dict];
    firebase = nil;
}

- (void)sendData:(NSDictionary *)dict ofRoomUid:(NSString *)roomUid atURL:(NSString *)urlString {
    Firebase *firebase = [[self generateFirebaseForURL:roomUid] childByAppendingPath:urlString];
    [firebase setValue:dict];
    firebase = nil;
}

#pragma mark - Access and Update Database
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
            
            if (block) { block(result, error); }
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
        
        if (block) { block(YES, error); }
    }];
}

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([GSSession isAuthenticated]) {
        [self.currentUser updateWithPFUser:[PFUser currentUser]
                                     block:^(BOOL succeed, NSError *error) {}];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([GSSession isAuthenticated]) {
        [self.currentUser updateWithPFUser:[PFUser currentUser]
                                     block:^(BOOL succeed, NSError *error) {
                                         [self goOnline:NO];
                                     }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([GSSession isAuthenticated]) {
        [self.currentUser updateWithPFUser:[PFUser currentUser]
                                     block:^(BOOL succeed, NSError *error) {
                                         [self goOnline:YES];
                                     }];
    }
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setBadge:0];
    [currentInstallation saveInBackground];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([GSSession isAuthenticated]) {
        [self.currentUser updateWithPFUser:[PFUser currentUser]
                                     block:^(BOOL succeed, NSError *error) {
                                         [self goOnline:NO];
                                     }];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PFInstallation currentInstallation] setBadge:0];
}

#pragma mark - Update User data
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
            NSString *email = userData[@"email"];
            NSString *username = userData[@"username"];
            NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=132&height=132", facebookID];
            
            [[PFUser currentUser] setObject:name forKey:@"fullname"];
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] setObject:pictureURL forKey:@"avatar_url"];
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"facebook_linked"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebook_id"];
            [[PFUser currentUser] setObject:username forKey:@"facebook_screen_name"];
            [[PFUser currentUser] saveInBackground];
        }
        if (block) { block(YES, error); }
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
            if (block) { block(succeeded, error); }
        }];
    } else {
        if (block) { block(NO, nil); }
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
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
}

- (void)goOnline:(BOOL)online {
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:online] forKey:@"is_online"];
    [[PFUser currentUser] saveInBackground];
    [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
}

- (void)updateUserDataWithBlock:(GSResultBlock)block {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (error) {
            if (block) { block(NO, error); }
        } else {
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] setObject:[NSDate date] forKey:@"last_log_in"];
            if (![[PFUser currentUser] objectForKey:@"fullname"]) {
                [[PFUser currentUser] setObject:[[PFUser currentUser] username] forKey:@"fullname"];
            }
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self goOnline:YES];
                [self initOrUpdateGSUser];
                if (block) { block(YES, error); }
            }];
        }
    }];
}

#pragma mark - Firebase
- (Firebase *)getMyBaseFirebase {
    return [self.firebase childByAppendingPath:[NSString stringWithFormat:@"User_%@", self.currentUser.uid]];
}

- (Firebase *)generateFirebaseForUser:(GSUser *)user atTime:(NSString *)time {
    Firebase *receiverBaseFirebase = [self.firebase childByAppendingPath:[NSString stringWithFormat:@"User_%@", user.uid]];
    Firebase *senderFirebaseInReceiverBaseFirebase = [receiverBaseFirebase childByAppendingPath:[NSString stringWithFormat:@"Sender_%@", self.currentUser.uid]];
    NSString *timeFirebaseName = [NSString stringWithFormat:@"%@_%@", self.currentUser.username, time];
    Firebase *timeFirebase = [senderFirebaseInReceiverBaseFirebase childByAppendingPath:timeFirebaseName];
    DLog(@"Create fire base: %@", [timeFirebase name]);
    return timeFirebase;
}

- (Firebase *)generateFirebaseForRoom:(GSRoom *)room {
    return [self.firebase childByAppendingPath:[room uid]];
}

- (Firebase *)generateFirebaseForURL:(NSString *)URL {
    return [self.firebase childByAppendingPath:URL];
}

#pragma mark - Push Notifications
- (void)sendPushNotificationMessage:(NSString *)message toUser:(GSUser *)user {
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"objectId" equalTo:user.uid];
    
    // Build the actual push notification target query
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" matchesQuery:innerQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:message, @"alert", @"Increment", @"badge", nil];
    [push setQuery:query];
    [push setData:data];
    [push sendPushInBackground];
}

#pragma mark - Conversion
- (FEventType)firebaseEventFromGSEvent:(GSEventType)eventType {
    switch (eventType) {
        case GSEventTypeChildAdded:
            return FEventTypeChildAdded;
        case GSEventTypeChildChanged:
            return FEventTypeChildChanged;
        case GSEventTypeChildMoved:
            return FEventTypeChildMoved;
        case GSEventTypeChildRemoved:
            return FEventTypeChildRemoved;
        default:
            return FEventTypeValue;
    }
}

#pragma mark - Supports
+ (void)showLoadingIndicatorWithMessage:(NSString *)message {
    [GSSVProgressHUD showWithStatus:message];
}

+ (void)dismissLoadingIndicator {
    [GSSVProgressHUD dismiss];
}

+ (NSString *)mySecretId {
    if ([[GSSession activeSession] mySecretId]) {
        return [[GSSession activeSession] mySecretId];
    } else  {
        [GSSession activeSession].mySecretId = [GSUtils getMacAddress];
        return [[GSSession activeSession] mySecretId];
    }
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
