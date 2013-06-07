//
//  ColorTabView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLauncherHeight (IS_IPAD ? 110 : 64)

@protocol ColorTabViewDelegate
- (void)selectColorTabAtIndex:(int)index;
- (void)showHidePicker;
@end

@interface ColorTabView : UIView

- (void)updateColorTab;

@property (nonatomic, strong) NSArray *tabArray;
@property (nonatomic, assign) id<ColorTabViewDelegate> delegate;

@end
