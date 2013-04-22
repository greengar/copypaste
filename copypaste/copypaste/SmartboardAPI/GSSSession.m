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

+ (GSSSession *)activeSession {
    static GSSSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [GSSSession new]; });
    return activeSession;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    [Parse setApplicationId:clientId clientKey:clientSecret];
    [PFFacebookUtils initializeFacebook];
}

+ (BOOL)isAuthenticated {
    return ([PFUser currentUser] != nil);
}

- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate {
    self.delegate = delegate;
    
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    
    // For next, we should allocate new Sign Up View Controller to be able to customize the UI
    logInController.signUpController.delegate = self;
    
    // We should check Facebook permissions for this
    NSArray *permissions = [NSArray arrayWithObjects:@"user_photos", @"publish_stream", @"offline_access", @"email", @"user_location", nil];
    [logInController setFacebookPermissions:permissions];
    [logInController setFields:PFLogInFieldsUsernameAndPassword
                             | PFLogInFieldsFacebook
                             | PFLogInFieldsSignUpButton
                             | PFLogInFieldsDismissButton];
    [viewController presentModalViewController:logInController animated:YES];
}

- (void)logOut {
    [PFUser logOut];
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
                        [nearByUserExceptMe addObject:user];
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

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
        self.delegate = nil;
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
