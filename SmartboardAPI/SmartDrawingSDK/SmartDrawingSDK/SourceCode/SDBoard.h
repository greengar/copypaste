//
//  SDBoard.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDUtils.h"
#import "SDPage.h"

@interface SDBoard : UIViewController <SDPageDelegate>

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, assign) id<SDRootViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImage *backgroundImage;
@end
