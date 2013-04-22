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
#import "CPUser.h"
#import "GSSSession.h"

@interface CPViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource, EGOImageViewDelegate,GSSSessionDelegate>

@property (nonatomic, retain) UILabel *pasteTitleLabel;
@property (nonatomic, retain) UIView *displayView;
@property (nonatomic, retain) UITextView *stringLabel;
@property (nonatomic, retain) UIImageView *imageHolderView;
@property (nonatomic, retain) UIButton *settingButton;

@property (nonatomic, retain) GMGridView *availableUsersGridView;

@end
