//
//  LogInViewController.m
//  copypaste
//
//  Created by Hector Zhao on 4/16/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController
@synthesize logInWithEmailBtn = _logInWithEmailBtn;
@synthesize logInWithFacebookBtn = _logInWithFacebookBtn;
@synthesize delegate = _delegate;

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logInWithEmailBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logInWithEmailBtn setFrame:CGRectMake(50, 200, 220, 50)];
    [self.logInWithEmailBtn setTitle:@"Log in" forState:UIControlStateNormal];
    [self.logInWithEmailBtn addTarget:self
                               action:@selector(logInWithEmail:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logInWithEmailBtn];
    
	self.logInWithFacebookBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.logInWithFacebookBtn setFrame:CGRectMake(50, 300, 220, 50)];
    [self.logInWithFacebookBtn setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [self.logInWithFacebookBtn addTarget:self
                             action:@selector(logInWithFacebook:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logInWithFacebookBtn];
}

- (void)logInWithEmail:(id)sender {
    [[GSSAuthenticationManager sharedManager] logInWithEmail:@"hector" password:@"123456" delegate:self];
}

- (void)logInWithFacebook:(id)sender {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Connection Required"
                                                            message:@"Please make sure you connect to the Internet!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         switch (state) {
             case FBSessionStateOpen: {
                 [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                     DLog(@"User name: %@", user.name);
                     DLog(@"User email: %@", [user objectForKey:@"email"]);
                     DLog(@"User display name: %@", user.username);
                     
                     [[GSSAuthenticationManager sharedManager] logInWithFacebookEmail:[user objectForKey:@"email"]
                                                                             username:user.name
                                                                             delegate:self];

                 }];
             }   break;
             case FBSessionStateClosed:
             case FBSessionStateClosedLoginFailed:
                 DLog(@"Log in failed");
                 break;
             default:
                 break;
         }
         
         if (error != nil) {
             if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
                 [self.delegate didLoginFailed:error];
             }
             DLog(@"Error, %@", error);
         }
     }];
}

#pragma mark -
#pragma mark REGISTER - LOG IN
- (void)registerWithEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)registerWithEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Failed"
                                                            message:[NSString stringWithFormat:@"%@", error]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)logInWithEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)logInWithEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in Failed"
                                                            message:[NSString stringWithFormat:@"%@", error]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)logInWithFacebookEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginSucceeded)]) {
        [self.delegate didLoginSucceeded];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)logInWithFacebookEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error {
    if (self.delegate
        && [((id) self.delegate) respondsToSelector:@selector(didLoginFailed:)]) {
        [self.delegate didLoginFailed:error];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log in with Facebook Failed"
                                                            message:[NSString stringWithFormat:@"%@", error]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
}

@end
