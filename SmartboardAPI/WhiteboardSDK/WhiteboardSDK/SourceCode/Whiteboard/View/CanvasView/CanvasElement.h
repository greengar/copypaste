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

@class CanvasElement;

@interface CanvasElement : WBBaseElement

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)updateBoundingRect:(CGRect)boundingRect;
- (void)takeScreenshot;
- (void)removeScreenshot;

@end
