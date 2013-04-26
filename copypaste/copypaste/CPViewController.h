//
//  CPViewController.h
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "GMGridView.h"
#import "EGOImageView.h"
#import "GSSession.h"
#import "GSObject.h"
#import "CPPasteboardView.h"
#import "CPMessageView.h"
#import "WEPopoverController.h"
#import "CPProfileViewController.h"

@interface CPViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource, EGOImageViewDelegate,GSSessionDelegate, WEPopoverControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) CPPasteboardView *myPasteboardHolderView;
@property (nonatomic, retain) WEPopoverController *userProfilePopoverController;
@property (nonatomic, retain) CPPasteboardView *otherPasteboardHolderView;

@property (nonatomic, retain) EGOImageView *avatarImageView;
@property (nonatomic, retain) UIButton *settingButton;

@property (nonatomic, retain) GMGridView *availableUsersGridView;

@end
