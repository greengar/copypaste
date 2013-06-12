//
//  CollaborativeViewController.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CollaborativeViewController.h"

@interface CollaborativeViewController ()

@end

@implementation CollaborativeViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([GSSession isAuthenticated]) {
        [authenticationButton setTitle:@"Log Out" forState:UIControlStateNormal];
        [logInLabel setText:[[GSSession activeSession] currentUserName]];
        [createRoomButton setHidden:NO];
        [getPublicRoomButton setHidden:NO];
        [getRoomByIdButton setHidden:NO];
        [getUserByEmailButton setHidden:NO];
    } else {
        [authenticationButton setTitle:@"Authenticate" forState:UIControlStateNormal];
        [logInLabel setText:@""];
        [createRoomButton setHidden:YES];
        [getPublicRoomButton setHidden:YES];
        [getRoomByIdButton setHidden:YES];
        [getUserByEmailButton setHidden:YES];
    }
}

- (IBAction)authenticate {
    if (![GSSession isAuthenticated]) {
        [[GSSession activeSession] authenticateSmartboardAPIFromViewController:self
                                                                      delegate:self];
    } else {
        [[GSSession activeSession] logOutWithBlock:^(BOOL succeed, NSError *error) {
            [self viewDidAppear:YES];
        }];
    }
}

- (void)didFinishAuthentication:(NSError *)error {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Failed"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        NSString *message = [NSString stringWithFormat:@"User: %@", [[GSSession currentUser] displayName]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Succeeded"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMessage:(NSDictionary *)dictInfo {
    NSString *message = [NSString stringWithFormat:@"Message: %@", dictInfo];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Succeeded"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
