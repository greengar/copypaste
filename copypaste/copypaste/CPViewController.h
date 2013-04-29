//
//  CPViewController.h
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Smartboard/Smartboard.h>
#import "DataManager.h"
#import "GMGridView.h"
#import "EGOImageView.h"
#import "CPPasteboardView.h"
#import "CPMessageView.h"
#import "WEPopoverController.h"
#import "CPProfileViewController.h"

@interface CPViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource, EGOImageViewDelegate,GSSessionDelegate, WEPopoverControllerDelegate, UIAlertViewDelegate, CPMessageViewDelegate>

@property (nonatomic, retain) CPPasteboardView *myPasteboardHolderView;
@property (nonatomic, retain) WEPopoverController *userProfilePopoverController;

@property (nonatomic, retain) EGOImageView *avatarImageView;
@property (nonatomic, retain) UIButton *settingButton;

@property (nonatomic, retain) GMGridView *availableUsersGridView;

@end
