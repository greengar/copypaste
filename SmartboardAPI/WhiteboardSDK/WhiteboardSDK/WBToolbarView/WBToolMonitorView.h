//
//  WBToolMonitorView.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorSpectrumImageView.h"
#import "CustomSlider.h"
#import "ColorPreviewView.h"

#define kWBToolMonitorWidth     [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPrivate.png"].size.width
#define kWBToolMonitorHeight    [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPrivate.png"].size.height

@protocol WBToolMonitorDelegate
- (void)colorPicked:(UIColor *)color;
- (void)opacityChanged:(float)opacity;
- (void)pointSizeChanged:(float)pointSize;
- (void)monitorClosed;
- (void)selectEraser:(BOOL)select;
@end

@interface WBToolMonitorView : UIView <ColorPickerImageViewDelegate>

@property (nonatomic, assign) id<WBToolMonitorDelegate> delegate;

@end
