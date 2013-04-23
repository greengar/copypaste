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
#import "GSSSession.h"

@interface CPViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource, EGOImageViewDelegate,GSSSessionDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UIView *myPasteboardHolderView;
@property (nonatomic, retain) UIImageView *myPasteboardBackgroundImageView;
@property (nonatomic, retain) UITextView *myPasteboardTextView;
@property (nonatomic, retain) UIScrollView *myPasteboardImageHolderView;
@property (nonatomic, retain) UIImageView *myPasteboardImageView;

@property (nonatomic, retain) EGOImageView *avatarImageView;
@property (nonatomic, retain) UIButton *settingButton;

@property (nonatomic, retain) GMGridView *availableUsersGridView;

@end
