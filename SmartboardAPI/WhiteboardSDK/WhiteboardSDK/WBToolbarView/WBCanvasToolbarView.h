//
//  WBCanvasToolbarView.h
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBCanvasToolbarDelegate
- (void)showColorSpectrum:(BOOL)show;
@end

@interface WBCanvasToolbarView : UIView

@property (nonatomic, assign) id<WBCanvasToolbarDelegate> delegate;

- (void)updateColor:(UIColor *)color;
- (void)updateAlpha:(float)alpha;
- (void)updatePointSize:(float)pointSize;
- (void)monitorClosed;
- (void)selectEraser:(BOOL)select;

@end
