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
#import "SDBaseView.h"

@interface SDBoard : UIViewController <SDPageDelegate, SDBaseViewDelegate>

- (void)setBackgroundImage:(UIImage *)image;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) id<SDBoardDelegate> delegate;

@end
