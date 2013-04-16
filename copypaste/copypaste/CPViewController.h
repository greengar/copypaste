//
//  CPViewController.h
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface CPViewController : UIViewController

@property (nonatomic, retain) UIView *displayView;
@property (nonatomic, retain) UITextView *stringLabel;
@property (nonatomic, retain) UIImageView *imageHolderView;

@end
