//
//  ColorTabView.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLauncherHeight 41

@protocol ColorTabViewDelegate
- (void)selectColorTabAtIndex:(int)index;
- (void)showHidePicker;
@end

@interface ColorTabView : UIView

- (void)finishShowHidePicker:(BOOL)isShown;
- (void)updateColorTab;

@property (nonatomic, strong) NSArray *tabArray;
@property (nonatomic, assign) id<ColorTabViewDelegate> delegate;

@end
