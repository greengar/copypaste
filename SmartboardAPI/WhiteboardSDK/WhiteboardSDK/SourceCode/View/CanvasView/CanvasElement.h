//
//  CanvasElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBBaseElement.h"
#import "MainPaintingView.h"
#import "ColorTabView.h"
#import "ColorPickerView.h"

@class CanvasElement;

@interface CanvasElement : WBBaseElement <ColorTabViewDelegate, ColorPickerViewDelegate, MainPaintViewDelegate>

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)takeScreenshot;
- (void)removeScreenshot;

@end
