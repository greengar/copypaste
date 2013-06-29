//
//  GLCanvasElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBBaseElement.h"
#import "MainPaintingView.h"

@class GLCanvasElement;

@interface GLCanvasElement : WBBaseElement <MainPaintViewDelegate>

- (void)takeScreenshot;
- (void)removeScreenshot;

@property (nonatomic) BOOL isCrop;
@property (nonatomic) CGRect boundingRect;

@end
