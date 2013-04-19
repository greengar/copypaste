//
//  GSSSession.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSSession.h"
#import "LogInViewController.h"

static GSSSession *activeSession = nil;

@interface GSSSession()
@property (nonatomic, retain) GSSAppInfo *appInfo;
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
        self.appInfo = [[GSSAppInfo alloc] init];
    }
    return self;
}

+ (void)setClientId:(NSString *)clientId {
    [[[GSSSession activeSession] appInfo] setClientId:clientId];
}

+ (void)setClientSecret:(NSString *)clientSecret {
    [[[GSSSession activeSession] appInfo] setClientSecret:clientSecret];
}

+ (NSString *)clientId {
    return [[[GSSSession activeSession] appInfo] clientId];
}

+ (NSString *)clientSecret {
    return [[[GSSSession activeSession] appInfo] clientSecret];
}

- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate {
    self.delegate = delegate;
    
    LogInViewController *logInViewController = [[LogInViewController alloc] init];
    [logInViewController setDelegate:self];
    [viewController presentModalViewController:logInViewController animated:YES];
}

- (void)didLoginSucceeded {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
    }
}

- (void)didLoginFailed:(NSError *)error {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
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
