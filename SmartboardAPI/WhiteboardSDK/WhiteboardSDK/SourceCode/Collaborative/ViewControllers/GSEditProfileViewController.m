//
//  GSEditProfileViewController.m
//  Whiteboard app
//
//  Created by Elliot Lee on 6/27/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "GSEditProfileViewController.h"
#import "GSSession.h"

@interface GSEditProfileViewController ()

@end

@implementation GSEditProfileViewController

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
    // Do any additional setup after loading the view from its nib.
    
    // darker red = C03F2C
    self.signOutButton.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOutTapped {
    [[GSSession activeSession] logOutWithBlock:^(BOOL succeed, NSError *error) {
        UIAlertView *alert;
        if (succeed) {
            alert = [[UIAlertView alloc] initWithTitle:@"Successfully Signed Out" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogOutNotification object:self];
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Sign Out Failed" message:nil delegate:nil cancelButtonTitle:@"Darn!" otherButtonTitles:nil];
        }
        [alert show];
    }];
    
//    [PFUser logOut];
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
