//
//  WBToolbarView.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"
#import "WBCanvasToolbarView.h"
#import "WBBottomRightToolbarView.h"

@protocol WBToolbarDelegate
- (void)canvasButtonTappedFrom:(UIView *)view;
- (void)selectHistoryColor;
- (void)addMoreButtonTappedFrom:(UIView *)view;
- (void)moveButtonTapped;
@end

@interface WBToolbarView : UIView <WBCanvasToolbarDelegate, WBBottomRightToolbarDelegate>

- (void)updateColor:(UIColor *)color;
- (void)updateAlpha:(float)alpha;
- (void)updatePointSize:(float)size;
- (void)selectCanvasMode:(CanvasMode)mode;

- (void)didShowMonitorView:(BOOL)success;
- (void)didShowAddMoreView:(BOOL)success;
- (void)didActivatedMove:(BOOL)success;

@property (nonatomic, assign) id<WBToolbarDelegate> delegate;

@end
