//
//  LogInViewController.h
//  copypaste
//
//  Created by Hector Zhao on 4/16/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "Reachability.h"
#import "GSSAuthenticationManager.h"
#import "GSSParseQueryHelper.h"

@protocol LogInViewControllerDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
@end

@interface LogInViewController : UIViewController <FBLoginViewDelegate, GSSAuthenticationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic, retain) UIButton *logInWithEmailBtn;
@property (nonatomic, retain) UIButton *logInWithFacebookBtn;
@property (nonatomic, assign) id<LogInViewControllerDelegate> delegate;
@end
