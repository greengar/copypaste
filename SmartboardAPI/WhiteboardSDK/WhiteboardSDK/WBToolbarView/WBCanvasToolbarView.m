//
//  WBCanvasToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasToolbarView.h"
#import "WBCanvasButton.h"
#import "WBHistoryColorButton.h"
#import "SettingManager.h"

@interface WBCanvasToolbarView()
@property (nonatomic, strong) WBCanvasButton *canvasButton;
@end

@implementation WBCanvasToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO; // necessary due to rounded corners
        
        self.canvasButton = [[WBCanvasButton alloc] initWithFrame:CGRectMake(self.frame.size.width-kCanvasButtonWidth,
                                                                             0, kCanvasButtonWidth, frame.size.height)];
        self.canvasButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.canvasButton addTarget:self action:@selector(showColorSpectrum:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.canvasButton];
        
        float barWidth = frame.size.width-kCanvasButtonWidth;
        float barHeight = frame.size.height;
        int count = [[[SettingManager sharedManager] colorTabList] count]-1; // Don't count eraser color
        for (int i = 0; i < count; i++) {
            WBHistoryColorButton *historyColorBtn = [[WBHistoryColorButton alloc] initWithFrame:CGRectMake(barWidth*(count-i-1)/count, 0, barWidth/count, barHeight)];
            [historyColorBtn setIndex:i];
            [historyColorBtn addTarget:self action:@selector(selectHistoryColor:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:historyColorBtn];
        }
    }
    return self;
}

- (void)showColorSpectrum:(WBCanvasButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showColorSpectrum:)]) {
        [self.delegate showColorSpectrum:!button.isSelected];
    }
    [button setSelected:!button.isSelected];
}

- (void)selectHistoryColor:(WBHistoryColorButton *)button {
    [[SettingManager sharedManager] setCurrentColorTab:button.index];
    [self selectEraser:NO];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectHistoryColor)]) {
        [self.delegate selectHistoryColor];
    }
}

- (void)updateColor:(UIColor *)color {
    for (UIView *subview in [self subviews]) {
        [subview setNeedsDisplay];
    }
}

- (void)updateAlpha:(float)alpha {
    for (UIView *subview in [self subviews]) {
        [subview setNeedsDisplay];
    }
}

- (void)updatePointSize:(float)pointSize {
    for (UIView *subview in [self subviews]) {
        [subview setNeedsDisplay];
    }
}

- (void)monitorClosed {
    [self.canvasButton setSelected:NO];
}

- (void)selectEraser:(BOOL)select {
    [self.canvasButton setEraserEnabled:select];
    for (UIView *subview in [self subviews]) {
        [subview setNeedsDisplay];
    }
}

@end
