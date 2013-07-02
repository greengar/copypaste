//
//  GSSignUpLogInViewController.m
//  Smartboard2
//
//  Created by Elliot Lee on 6/28/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "GSSignUpLogInViewController.h"
#import "GSSignUpViewController.h"
#import "GSLogInViewController.h"
#import "WBUtils.h"
#import "GSUtils.h"

@interface GSSignUpLogInViewController ()
{
    UILabel *logoView;
    GSSignUpViewController *signUpViewController;
    GSLogInViewController *logInViewController;
    CGRect signUpViewActiveRect;
}
@end

@implementation GSSignUpLogInViewController

static const CGFloat signInHeaderHeight = 100;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    logoView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 768, 200)];
    logoView.text = @"Whiteboard";
    logoView.textAlignment = NSTextAlignmentCenter;
    logoView.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:88];
    [self.view addSubview:logoView];
    
    logInViewController = [[GSLogInViewController alloc] init];
    logInViewController.view.frame = CGRectMake(0, X(logoView) + H(logoView), self.view.frame.size.width, signInHeaderHeight);
    logInViewController.view.clipsToBounds = YES;
    [self.view addSubview:logInViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInHeaderTapped) name:kSignInHeaderTappedNotification object:nil];
    
    signUpViewController = [[GSSignUpViewController alloc] init];
    signUpViewActiveRect = CGRectMake(0, X(logoView) + H(logoView) + signInHeaderHeight, W(self.view), H(self.view) - signInHeaderHeight);
    signUpViewController.view.frame = signUpViewActiveRect;
    signUpViewController.view.clipsToBounds = YES;
    signUpViewController.lineView.hidden = YES;
    [self.view addSubview:signUpViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpHeaderTapped) name:kSignUpHeaderTappedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogIn) name:kDidLogInNotification object:nil];
}

- (void)didLogIn
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signInHeaderTapped
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:1 animations:^{
        logInViewController.view.frame = CGRectMake(0, X(logoView) + H(logoView), self.view.frame.size.width, H(self.view) - signInHeaderHeight);
        logInViewController.bottomLineView.hidden = YES;
        signUpViewController.view.frame = CGRectMake(0, self.view.frame.size.height - signInHeaderHeight, self.view.frame.size.width, signInHeaderHeight);
    } completion:^(BOOL finished) { }];
}

- (void)signUpHeaderTapped
{
    [UIView animateWithDuration:1 animations:^{
        logInViewController.view.frame = CGRectMake(0, X(logoView) + H(logoView), W(self.view), signInHeaderHeight);
        signUpViewController.view.frame = signUpViewActiveRect;
    } completion:^(BOOL finished) {
        if (finished)
            logInViewController.bottomLineView.hidden = NO;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
