//
//  GSLogInViewController.m
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/22/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSLogInViewController.h"
#import "UIColor+GSExpanded.h"
#import <QuartzCore/QuartzCore.h>
#import "UITextField+GSCustomPlaceholderTextColor.h"
#import "GSTheme.h"

@interface GSLogInViewController ()

@property (nonatomic, strong) UIView *fieldsBackground;

@end

@implementation GSLogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIColor *bgColor = [UIColor colorWithHexString:@"E1CAA7"];
    
    // logo can be a UIImageView, but in our case it's a label
    self.logInView.logo = [GSTheme logoWithSize:42];
    
    /**(1)** Build the NSAttributedString *******/
//    NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:@"Hello World!"];
//    // for those calls we don't specify a range so it affects the whole string
//    [attrStr setFont:[UIFont systemFontOfSize:12]];
//    [attrStr setTextColor:[UIColor grayColor]];
//    // now we only change the color of "Hello"
//    [attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];
//    
//    OHAttributedLabel *myAttributedLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(20, 70, 300, 54)];
//    
//    /**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
//    myAttributedLabel.attributedText = attrStr;
    // Use the "Justified" alignment
//    myAttributedLabel.textAlignment = UITextAlignmentJustify;
    
//    myAttributedLabel.textAlignment = kCTJustifiedTextAlignment;
    
    // "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
    
    
    
    [self.logInView setBackgroundColor:bgColor]; // beige
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    
    

    
//    self.logInView.logo = myAttributedLabel;
    
    
    
    
//    NSMutableAttributedString
//    label.attributedText
    
    
    // Set buttons appearance
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"exit.png"] forState:UIControlStateNormal];
//    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"exit_down.png"] forState:UIControlStateHighlighted];
    
//    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
//    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
//    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_down.png"] forState:UIControlStateHighlighted];
//    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
//    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
//    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
//    [self.logInView.twitterButton setImage:nil forState:UIControlStateHighlighted];
//    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
//    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_down.png"] forState:UIControlStateHighlighted];
//    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateHighlighted];
    
//    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup.png"] forState:UIControlStateNormal];
//    [self.logInView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signup_down.png"] forState:UIControlStateHighlighted];
//    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
//    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    // Add login field background
//    self.fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    const float margin = 38;
    const float width = self.logInView.frame.size.width - 2 * margin;
    const float height = 90;
    const float topOfTextFieldToBottomOfView = 315;
    UIView *v = [[UIView alloc] initWithFrame:
                 CGRectMake(0, 0,
                            width, height)];
    v.center = CGPointMake(320 / 2, self.logInView.frame.size.height - topOfTextFieldToBottomOfView + (100 / 2));
//    v.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;// | UIViewAutoresizingFlexibleHeight;
    v.backgroundColor = [UIColor colorWithHexString:@"87C2C8"]; // blue
    v.layer.cornerRadius = 5;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, v.frame.size.height / 2, v.frame.size.width, 1)];
    line.backgroundColor = bgColor;
    [v addSubview:line];
    
    self.fieldsBackground = v;
    [self.logInView insertSubview:self.fieldsBackground atIndex:1];
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    
    // Set field text color
//    [self.logInView.usernameField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
//    [self.logInView.passwordField setTextColor:[UIColor colorWithRed:135.0f/255.0f green:118.0f/255.0f blue:92.0f/255.0f alpha:1.0]];
//    UITextField *f =  [self.logInView.usernameField copy];
    
    [self.logInView.usernameField setTextColor:[UIColor colorWithHexString:@"1A3C3C"]];
    [self.logInView.passwordField setTextColor:[UIColor colorWithHexString:@"1A3C3C"]];
    //@"FE8C0E"
    
    [self.logInView.usernameField setPlaceholderTextColor:[UIColor colorWithHexString:@"419394"]];
    [self.logInView.passwordField setPlaceholderTextColor:[UIColor colorWithHexString:@"419394"]];
    
    [self.logInView.externalLogInLabel removeFromSuperview];
    [self.logInView.signUpLabel removeFromSuperview];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
//    [self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    //[self.logInView.logo setFrame:CGRectMake(66.5f, 70.0f, 187.0f, 58.5f)];
//    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.twitterButton setFrame:CGRectMake(35.0f+130.0f, 287.0f, 120.0f, 40.0f)];
//    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
//    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
//    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
//    [self.fieldsBackground setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 100.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
