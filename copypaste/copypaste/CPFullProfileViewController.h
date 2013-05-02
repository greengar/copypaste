//
//  CPFullProfileViewController.h
//  copypaste
//
//  Created by Hector Zhao on 5/1/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "CPUser.h"
#import "CPNavigationView.h"

@interface CPFullProfileViewController : UIViewController <EGOImageViewDelegate, CPNavigationDelegate>

@property (nonatomic, strong) CPUser *profileUser;
@property (nonatomic, strong) UILabel *profileSentMsgNumLabel;
@end
