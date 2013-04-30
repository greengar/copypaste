//
//  CPSignUpViewController.m
//  copypaste
//
//  Created by Elliot Lee on 4/27/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSignUpViewController.h"
#import "UIColor+GSExpanded.h"
#import <QuartzCore/QuartzCore.h>
#import "UITextField+GSCustomPlaceholderTextColor.h"

#define kSignUpFieldsBackgroundHeight (135)

@interface GSSignUpViewController ()
@property (nonatomic, strong) UIView *fieldsBackground;
@end

@implementation GSSignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *bgColor = [UIColor colorWithHexString:@"E1CAA7"];
    
    [self.signUpView setBackgroundColor:bgColor];
    [self.signUpView setLogo:nil];

    // Change button apperance
//    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"Exit.png"] forState:UIControlStateNormal];
//    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"ExitDown.png"] forState:UIControlStateHighlighted];
//    
//    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUp.png"] forState:UIControlStateNormal];
//    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignUpDown.png"] forState:UIControlStateHighlighted];
//    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
//    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    // Add background for fields
    
    // Move all fields down on smaller screen sizes
    float yOffset = 0.0f; //[UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    
    const float margin = 37;
    const float width = self.signUpView.frame.size.width - 2 * margin - 2; // fudge
    
    const float centerY = fieldFrame.origin.y + yOffset + (kSignUpFieldsBackgroundHeight / 2);
    
    UIView *v = [[UIView alloc] initWithFrame:
                 CGRectMake(0.0f, 0.0f,
                            width, kSignUpFieldsBackgroundHeight)];
    v.center = CGPointMake(320.0f / 2.0f, centerY);
    
    v.backgroundColor = [UIColor colorWithHexString:@"87C2C8"]; // blue
    v.layer.cornerRadius = 5;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, v.frame.size.height / 3, v.frame.size.width, 1)];
    line.backgroundColor = bgColor;
    [v addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, v.frame.size.height * 2 / 3, v.frame.size.width, 1)];
    line.backgroundColor = bgColor;
    [v addSubview:line];
    
    self.fieldsBackground = v;
    
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.additionalField.layer;
    layer.shadowOpacity = 0.0f;
    
    // Set text color
    UIColor *textColor = [UIColor colorWithHexString:@"1A3C3C"];
    
    [self.signUpView.usernameField setTextColor:textColor];
    // [UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    [self.signUpView.passwordField setTextColor:textColor];
    [self.signUpView.emailField setTextColor:textColor];
    
//    [self.signUpView.additionalField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
    
    UIColor *placeholderTextColor = [UIColor colorWithHexString:@"419394"];
    [self.signUpView.usernameField setPlaceholderTextColor:placeholderTextColor];
    [self.signUpView.passwordField setPlaceholderTextColor:placeholderTextColor];
    [self.signUpView.emailField setPlaceholderTextColor:placeholderTextColor];
    
    // Change "Additional" to match our use
//    [self.signUpView.additionalField setPlaceholder:@"Phone number"];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float yOffset = 0.0f; //[UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    CGRect fieldFrame = self.signUpView.usernameField.frame;
    
    const float centerY = fieldFrame.origin.y + yOffset + (kSignUpFieldsBackgroundHeight / 2);
    self.fieldsBackground.center = CGPointMake(320.0f / 2.0f, centerY);
    
    // Move all fields down on smaller screen sizes
//    float yOffset = [UIScreen mainScreen].bounds.size.height <= 480.0f ? 30.0f : 0.0f;
    
//    CGRect fieldFrame = self.signUpView.usernameField.frame;
//
//    [self.signUpView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
//    [self.signUpView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
//    [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, fieldFrame.origin.y + yOffset, 250.0f, 174.0f)];
    
//
//    [self.signUpView.usernameField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                       fieldFrame.origin.y + yOffset,
//                                                       fieldFrame.size.width - 10.0f,
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.passwordField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                       fieldFrame.origin.y + yOffset,
//                                                       fieldFrame.size.width - 10.0f,
//                                                       fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.emailField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                    fieldFrame.origin.y + yOffset,
//                                                    fieldFrame.size.width - 10.0f,
//                                                    fieldFrame.size.height)];
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x + 5.0f,
//                                                         fieldFrame.origin.y + yOffset,
//                                                         fieldFrame.size.width - 10.0f,
//                                                         fieldFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
