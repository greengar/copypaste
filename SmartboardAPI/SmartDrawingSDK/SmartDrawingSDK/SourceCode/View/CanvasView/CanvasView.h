//
//  CanvasView.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDBaseView.h"
#import "MainPaintingView.h"
#import "ColorTabView.h"
#import "ColorPickerView.h"

@interface CanvasView : SDBaseView <ColorTabViewDelegate, ColorPickerViewDelegate, MainPaintViewDelegate>

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end