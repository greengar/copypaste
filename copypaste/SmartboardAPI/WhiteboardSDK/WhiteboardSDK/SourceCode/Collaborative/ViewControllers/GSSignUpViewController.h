//
//  GSSignUpViewController.h
//  Collaborative SDK
//
//  Created by Elliot Lee on 4/27/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#define kSignUpHeaderTappedNotification @"kSignUpHeaderTappedNotification"

@interface GSSignUpViewController : UIViewController
{
    IBOutlet UIButton *expandButton;
    IBOutlet UIView *logoView;
    IBOutlet UIButton *facebookButton;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *emailField;
    IBOutlet UIButton *signUpButton;
}

@property (weak, nonatomic) IBOutlet UIView *lineView;

- (IBAction)signUpButtonTapped;
- (IBAction)signUpHeaderTapped;
- (IBAction)facebookButtonPressed:(id)sender;

@end
