//
//  GSSSession.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "GSSAppInfo.h"
#import "GSSEndpoint.h"
#import "LogInViewController.h"

@protocol GSSSessionDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
@end

@interface GSSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, LogInViewControllerDelegate>

+ (GSSSession *) activeSession;

+ (void)setClientId:(NSString *)clientId;
+ (void)setClientSecret:(NSString *)clientSecret;
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate;

+ (NSString *)clientId;
+ (NSString *)clientSecret;

@property (nonatomic, assign) id<GSSSessionDelegate> delegate;
@end
