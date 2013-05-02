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
#import "CPShortProfileViewController.h"
#import "CPFriendListViewController.h"
#import "CPUserView.h"

@interface CPViewController : UIViewController <EGOImageButtonDelegate,GSSessionDelegate, WEPopoverControllerDelegate, UIAlertViewDelegate, CPMessageViewDelegate, CPUserViewDelegate>

@property (nonatomic, strong) CPPasteboardView *myPasteboardHolderView;
@property (nonatomic, strong) WEPopoverController *userProfilePopoverController;

@property (nonatomic, strong) EGOImageButton *avatarImageButton;
@property (nonatomic, strong) UIButton *helpButton;

@property (nonatomic, strong) NSMutableArray *userViews;
@property (nonatomic, strong) UIButton *moreUsersButton;

@end
