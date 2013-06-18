//
//  WBCanvasButton.h
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCanvasButtonWidth 79

@interface WBCanvasButton : UIButton

@property float radius;
@property float lineWidth;
@property BOOL noGradient;
@property (nonatomic, retain) UIColor*  fillColor;
@property (nonatomic, retain) UIColor*  strokeColor;
@property (nonatomic, retain) UIColor*  tapColor;
@property (nonatomic, retain) UIColor*  tapStrokeColor;

@end
