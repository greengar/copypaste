//
//  GSLogInViewController.m
//  Collaborative SDK
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "GSLogInViewController.h"

#import "UITextField+GSCustomPlaceholderTextColor.h"
#import "UIColor+GSExpanded.h"
#import "GSSVProgressHUD.h"
#import "GSTheme.h"
#import "GSUtils.h"

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface GSLogInViewController () <UITextFieldDelegate>
{
    BOOL isRetrying;
}
@end

@implementation GSLogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    usernameField.placeholderTextColor = [UIColor colorWithHexString:@"929395"];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    leftView.backgroundColor = usernameField.backgroundColor;
    usernameField.leftView = leftView;
    usernameField.leftViewMode = UITextFieldViewModeAlways;
    usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    passwordField.placeholderTextColor = [UIColor colorWithHexString:@"929395"];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    leftView.backgroundColor = passwordField.backgroundColor;
    passwordField.leftView = leftView;
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    signInButton.layer.cornerRadius = 5;
}

- (IBAction)signInHeaderTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSignInHeaderTappedNotification object:self];
}

// TODO: code is duplicated in SignUpViewController
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

- (IBAction)forgotPasswordTapped
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter your email address.", nil)
                                                    message:NSLocalizedString(@"We will send an email with a link to reset your password", nil) delegate:self  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *t = [alert textFieldAtIndex:0];
    t.keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (isRetrying){
        [self forgotPasswordTapped];
        isRetrying = NO;
    }else {
        if (buttonIndex == 1){
            NSString *email = [alertView textFieldAtIndex:0].text;
            if ([GSUtils NSStringIsValidEmail:email]) {
                [GSSVProgressHUD show];
                [PFUser requestPasswordResetForEmailInBackground: email block:^(BOOL success, NSError *error){
                    [GSSVProgressHUD dismiss];
                    if (success) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email sent!", nil) message:NSLocalizedString(@"Check your mail inbox and reset your password.", nil) delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        DLog(@"Failed %@", [error description]);
                        NSString *errorMsg = nil;
                        switch (error.code) {
                            case 125:
                                errorMsg = NSLocalizedString(@"Invalid email address. Try again!", nil);
                                break;
                            default:
                                errorMsg = NSLocalizedString(@"Invalid email address. Try again!", nil);
                                break;
                        }
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                        message: errorMsg delegate:self  cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [alert show];
                        isRetrying = YES;
                    }
                }];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField){
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField){
        [textField resignFirstResponder];
        [self signInButtonTapped];
    }
    return YES;
}

- (IBAction)signInButtonTapped
{
    NSString *username = usernameField.text;
    NSString *password = passwordField.text;
    
    if (!VALID_STR(username) || !VALID_STR(password)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Username should be lowercase
    username = [username lowercaseString];
    
    // Login
    [self.view endEditing:YES];
    [GSSVProgressHUD show];
    [PFUser logInWithUsernameInBackground: username password:password block:^(PFUser *user, NSError *error){
        [GSSVProgressHUD dismiss];
        if (user) {
            
            // calls -updateUserInfoAndShowOrganizerIfLoggedIn
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogInNotification object:self];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Error", nil) message:NSLocalizedString(@"Invalid username/password. Try again!", nil) delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
