//
//  GSEditProfileViewController.h
//  Whiteboard app
//
//  Created by Elliot Lee on 6/27/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDidLogOutNotification @"kDidLogOutNotification"

@interface GSEditProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

- (IBAction)signOutTapped;

@end
