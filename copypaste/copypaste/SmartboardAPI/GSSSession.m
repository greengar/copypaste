//
//  GSSSession.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSSession.h"
#import "GSSParseQueryHelper.h"

static GSSSession *activeSession = nil;

@interface GSSSession()

@end

@implementation GSSSession
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
        self.currentUser = [[GSSUser alloc] init];
    }
    return self;
}

+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    [Parse setApplicationId:clientId clientKey:clientSecret];
    [PFFacebookUtils initializeFacebook];
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
                if ([nearByUserExceptMe count] > 0) {
                    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didGetNearbyUserSucceeded:)]) {
                        [self.delegate didGetNearbyUserSucceeded:nearByUserExceptMe];
                    }
                } else {
                    
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

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
        self.delegate = nil;
        
        if (self.currentUser == nil) {
            self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
        } else {
            [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
        }
        
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
                    [[PFUser currentUser] saveInBackground];
                    
                    // Parse again with new data
                    if (self.currentUser == nil) {
                        self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
                    } else {
                        [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
                    }
                }
            }];
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
        [self.delegate didLoginSucceeded];
        self.delegate = nil;
        
        if (self.currentUser == nil) {
            self.currentUser = [[GSSUser alloc] initWithPFUser:[PFUser currentUser]];
        } else {
            [self.currentUser parseDataFromPFUser:[PFUser currentUser]];
        }
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
