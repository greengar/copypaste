//
//  CPShortProfileViewController.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUser.h"
#import "EGOImageView.h"

@interface CPShortProfileViewController : UIViewController <EGOImageViewDelegate>

@property (nonatomic, retain) CPUser *profileUser;

@end
