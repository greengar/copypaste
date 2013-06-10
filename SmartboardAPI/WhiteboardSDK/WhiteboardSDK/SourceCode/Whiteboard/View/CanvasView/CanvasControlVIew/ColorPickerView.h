//
//  ColorPickerView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kColorPickerViewHeight 257

@protocol ColorPickerViewDelegate
- (void)updateSelectedColor;
@end

@interface ColorPickerView : UIView

- (void)selectColorTabAtIndex:(int)index;

@property (nonatomic, assign) id<ColorPickerViewDelegate> delegate;

@end
