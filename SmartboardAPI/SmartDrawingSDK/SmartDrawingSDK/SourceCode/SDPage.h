//
//  SDPage.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseElement.h"
#import "CanvasElement.h"
#import "FontPickerView.h"
#import "FontColorPickerView.h"

@class SDPage;

@protocol SDPageDelegate
@optional
- (void)pageSelected:(SDPage *)page;
- (void)doneEditingPage:(SDPage *)page;
@end

@interface SDPage : UIView <UIScrollViewDelegate, UIAlertViewDelegate, SDBaseViewDelegate>

- (void)setBackgroundImage:(UIImage *)image;
- (void)select;
- (NSDictionary *)saveToDict;
+ (SDPage *)loadFromDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic, strong) SDBaseElement *selectedElementView;
@property (nonatomic, assign) id<SDPageDelegate> delegate;

@end
