//
//  GSLogInViewController.h
//  Collaborative SDK
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#define kSignInHeaderTappedNotification @"kSignInHeaderTappedNotification"

@interface GSLogInViewController : UIViewController
{
    IBOutlet UIView *topLineView;
    IBOutlet UIButton *signInHeaderButton;
    IBOutlet UIView *logoView;
    IBOutlet UIButton *facebookButton;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIButton *forgotPasswordButton;
    IBOutlet UIButton *signInButton;
}

@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

- (IBAction)signInHeaderTapped;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)forgotPasswordTapped;
- (IBAction)signInButtonTapped;

@end
