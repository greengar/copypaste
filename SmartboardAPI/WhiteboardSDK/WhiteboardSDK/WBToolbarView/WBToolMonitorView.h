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
#import "SettingManager.h"

#define kWBToolMonitorWidth     [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPrivate.png"].size.width
#define kWBToolMonitorHeight    [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPrivate.png"].size.height

@protocol WBToolMonitorDelegate
- (void)colorPicked:(UIColor *)color;
- (void)opacityChanged:(float)opacity;
- (void)pointSizeChanged:(float)pointSize;
- (void)monitorClosed;
- (void)selectEraser:(BOOL)select;
- (void)fontChanged:(NSString *)fontName;
@end

@interface WBToolMonitorView : UIView <ColorPickerImageViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<WBToolMonitorDelegate> delegate;

@property (nonatomic) NSString *currentFont;
@property (nonatomic) BOOL textMode;

- (void)animateUp;
- (void)animateDown;
- (void)enableEraser:(BOOL)enable;
- (void)scrollFontTableViewToFont:(NSString *)font;

@end
