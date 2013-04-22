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
    // And remmeber to add the Facebook App Id
    [logInController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
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
        PFQuery *query = [PFQuery queryWithClassName:@"Location"];
        [query setLimit:1000];
        [query whereKey:@"location"
           nearGeoPoint:currentLocation];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    DLog(@"Geo: %@", object);
                }
            }
        }];
    }
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
