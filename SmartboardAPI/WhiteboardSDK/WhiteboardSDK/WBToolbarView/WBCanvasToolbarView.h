//
//  WBCanvasToolbarView.h
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBCanvasButton.h"

@protocol WBCanvasToolbarDelegate
- (void)canvasButtonTapped;
- (void)selectHistoryColor;
@end

@interface WBCanvasToolbarView : UIView

@property (nonatomic, assign) id<WBCanvasToolbarDelegate> delegate;

- (void)updateColor:(UIColor *)color;
- (void)updateAlpha:(float)alpha;
- (void)updatePointSize:(float)pointSize;
- (void)didShowMonitorView:(BOOL)success;

- (void)selectCanvasMode:(CanvasMode)mode;

@end
