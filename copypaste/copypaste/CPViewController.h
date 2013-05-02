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
#import "EGOImageView.h"
#import "CPPasteboardView.h"
#import "CPMessageView.h"
#import "WEPopoverController.h"
#import "CPProfileViewController.h"
#import "CPFriendListViewController.h"
#import "CPUserView.h"

@interface CPViewController : UIViewController <EGOImageButtonDelegate,GSSessionDelegate, WEPopoverControllerDelegate, UIAlertViewDelegate, CPMessageViewDelegate, CPUserViewDelegate, CPFriendListViewDelegate>

@property (nonatomic, retain) CPPasteboardView *myPasteboardHolderView;
@property (nonatomic, retain) WEPopoverController *userProfilePopoverController;

@property (nonatomic, retain) EGOImageButton *avatarImageButton;
@property (nonatomic, retain) UIButton *helpButton;

@property (nonatomic, strong) NSMutableArray *userViews;
@property (nonatomic, strong) UIButton *moreUsersButton;

@end
