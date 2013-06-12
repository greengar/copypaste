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

- (IBAction)createRoom {
    [[GSSession activeSession] createRoomWithName:@"Hector Room"
                                        isPrivate:YES
                                      codeToEnter:nil
                                        shareWith:nil
                                            block:^(id object, NSError *error) {
        if (error || !object) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error description]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            GSRoom *room = (GSRoom *)object;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Room created"
                                                                message:[room name]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)getAllPublicRoom {
    [[GSSession activeSession] getAllAvailableRoomWithBlock:^(NSArray *objects, NSError *error) {
        if (error || [objects count] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not found"
                                                                message:@"No public room"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            NSMutableString *message = [NSMutableString stringWithString:@"Room: "];
            for (GSRoom *room in objects) {
                [message appendFormat:@" %@", [room name]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Room found"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)getRoomById {
    [[GSSession activeSession] getRoomWithCode:@"Hector" block:^(id object, NSError *error) {
        if (error || !object) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not found"
                                                                message:@"No room found for code 'Hector'"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            NSString *message = [NSString stringWithFormat:@"Room: %@", [((GSRoom *) object) name]];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Room found for code 'Hector'"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)getUserByEmail {
    NSString *email = @"long@greengar.com";
    [[GSSession activeSession] getUsersByEmail:email block:^(NSArray *objects, NSError *error) {
        if (error || [objects count] == 0) {
            NSString *message = [NSString stringWithFormat:@"No user with email %@", email];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not found"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            NSString *title = [NSString stringWithFormat:@"User with email %@", email];
            NSMutableString *message = [NSMutableString stringWithString:@"User: "];
            for (GSUser *user in objects) {
                [message appendFormat:@" %@", [user displayName]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
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
