//
//  CPProfileViewController.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSSUser.h"
#import "EGOImageView.h"

@interface CPProfileViewController : UIViewController <EGOImageViewDelegate>

@property (nonatomic, retain) GSSUser *profileUser;

@end
