//
//  GSSignUpViewController.m
//  Collaborative SDK
//
//  Created by Elliot Lee on 4/27/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "GSSignUpViewController.h"

#import "UITextField+GSCustomPlaceholderTextColor.h"
#import "UIColor+GSExpanded.h"
#import "GSSVProgressHUD.h"
#import "GSTheme.h"
#import "GSUtils.h"

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

#define MIN_PASSWORD_LENGTH 6

@interface GSSignUpViewController () <UITextFieldDelegate>

@end

@implementation GSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden = YES;
    
    // unda doesn't do this here
//    self.facebookPermissions = @[@"read_friendlists", @"user_about_me"];
    
    usernameField.placeholderTextColor = [UIColor colorWithHexString:@"929395"];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    leftView.backgroundColor = usernameField.backgroundColor;
    usernameField.leftView = leftView;
    usernameField.textColor = [GSTheme textFieldTextColor];
    usernameField.font = [GSTheme textFieldFont];
    usernameField.leftViewMode = UITextFieldViewModeAlways;
    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    // There's a strange bug where this does not work on the placeholder text:
//    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    passwordField.placeholderTextColor = [UIColor colorWithHexString:@"929395"];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    leftView.backgroundColor = passwordField.backgroundColor;
    passwordField.leftView = leftView;
    passwordField.textColor = [GSTheme textFieldTextColor];
    passwordField.font = [GSTheme textFieldFont];
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    emailField.placeholderTextColor = [UIColor colorWithHexString:@"929395"];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    leftView.backgroundColor = emailField.backgroundColor;
    emailField.leftView = leftView;
    emailField.textColor = [GSTheme textFieldTextColor];
    emailField.font = [GSTheme textFieldFont];
    emailField.leftViewMode = UITextFieldViewModeAlways;
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    signUpButton.layer.cornerRadius = 5;
}

//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear: animated];
//    self.navigationController.navigationBarHidden = YES;
//}

- (void)showPasswordTooShortAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password too short" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)showInvalidEmailAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid email" message:@"We need your email in case you forget your password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
        if (passwordField.text.length < MIN_PASSWORD_LENGTH) {
            [self showPasswordTooShortAlert];
        } else {
            [emailField becomeFirstResponder];
        }
    } else if (textField == emailField) {
        if ([GSUtils NSStringIsValidEmail:emailField.text] == NO) {
            [self showInvalidEmailAlert];
        } else {
            [self signUpButtonTapped];
        }
    }
    return YES;
}

- (IBAction)signUpButtonTapped
{
    // make all usernames lowercase
    NSString *username = [usernameField.text lowercaseString];
    NSString *password = passwordField.text;
    NSString *email = emailField.text;
    
    if (!username || username.length == 0 || [username isAlphaNumeric] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username missing or invalid" message:@"Letters and numbers only" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!password || password.length < MIN_PASSWORD_LENGTH) {
        [self showPasswordTooShortAlert];
        return;
    }
    
    if (!email || email.length < 5 || [GSUtils NSStringIsValidEmail:email] == NO) {
        [self showInvalidEmailAlert];
        return;
    }
    
    [GSSVProgressHUD show];
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    [user signUpInBackgroundWithBlock:^(BOOL success, NSError *error) {
        [GSSVProgressHUD dismiss];
        if (success) {
            
            [PFCloud callFunctionInBackground:@"sendConfirmation"
                               withParameters:@{@"toAddress": user.email}
                                        block:^(id result, NSError *error) {
                                            if (!error) {
                                                DLog(@"%@", result);
                                            } else {
                                                DLog(@"error = %@", error);
                                                #if CRITTERCISM
                                                    NSException *exception = [NSException exceptionWithName:@"sendConfirmation" reason:@"error" userInfo:@{@"error":error}];
                                                    [Crittercism logHandledException:exception];
                                                #endif
                                            }
                                        }];
            
            [GSSVProgressHUD showSuccessWithStatus:@"Sign Up Done"];
            
            // Start login
            [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                [GSSVProgressHUD dismiss];
                if (user) {
                    // calls -updateUserInfoAndShowOrganizerIfLoggedIn
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogInNotification object:self];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign in failed" message:@"Invalid username or password. Try again!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        } else {
            NSString *reason = [[error userInfo] objectForKey:@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:reason delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)signUpHeaderTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSignUpHeaderTappedNotification object:self];
}

- (IBAction)facebookButtonPressed:(id)sender {
    [GSSVProgressHUD show];
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [PFFacebookUtils logInWithPermissions: nil block:^(PFUser *user, NSError *error){
        [GSSVProgressHUD dismiss];
        
        if (user && error == nil){
            [GSSVProgressHUD show];
            // calls -updateUserInfoAndShowOrganizerIfLoggedIn
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogInNotification object:self];
        }
        if (error) {
            BOOL isOS6 = NO; // or higher
            float currentVersion = 6.0;
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
            {
                isOS6 = YES; // or higher
            }
            if (isOS6) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Facebook Login failed. Check your settings in Settings > Facebook, please!", nil) delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Error: Facebook Login failed", nil) delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

//- (IBAction) dismissButtonPressed:(id)sender
//{
//    [self.navigationController popToRootViewControllerAnimated: YES];
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

@end
