//
//  GSSSession.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol GSSSessionDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
@end

@interface GSSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

+ (GSSSession *) activeSession;
+ (BOOL)isAuthenticated;
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate;

@property (nonatomic, assign) id<GSSSessionDelegate> delegate;
@end
