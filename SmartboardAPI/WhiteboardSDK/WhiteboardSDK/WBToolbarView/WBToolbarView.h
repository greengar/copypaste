//
//  WBToolbarView.h
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBCanvasToolbarView.h"
#import "WBBottomRightToolbarView.h"

@protocol WBToolbarDelegate
- (void)showColorSpectrum:(BOOL)show from:(UIView *)view;
- (void)selectHistoryColor;
- (void)showAddMore:(BOOL)show from:(UIView *)view;
- (void)enableMove:(BOOL)enable;
@end

@interface WBToolbarView : UIView <WBCanvasToolbarDelegate, WBBottomRightToolbarDelegate>

- (void)updateColor:(UIColor *)color;
- (void)updateAlpha:(float)alpha;
- (void)updatePointSize:(float)size;
- (void)monitorClosed;
- (void)bottomRightClosed;
- (void)selectEraser:(BOOL)select;

@property (nonatomic, assign) id<WBToolbarDelegate> delegate;

@end
