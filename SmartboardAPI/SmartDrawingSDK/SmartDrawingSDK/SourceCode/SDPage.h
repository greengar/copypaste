//
//  SDPage.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseView.h"
#import "CanvasView.h"
#import "FontPickerView.h"
#import "FontColorPickerView.h"

@class SDPage;

@protocol SDPageDelegate
@optional
- (void)pageSelected:(SDPage *)page;
- (void)doneEditingPage:(SDPage *)page;
@end

@interface SDPage : UIView <UIScrollViewDelegate, UIAlertViewDelegate, SDBaseViewDelegate, CanvasViewDelegate>

- (void)setBackgroundImage:(UIImage *)image;
- (void)select;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *elementViews;
@property (nonatomic, strong) SDBaseView *selectedElementView;
@property (nonatomic, assign) id<SDPageDelegate> delegate;

@end
