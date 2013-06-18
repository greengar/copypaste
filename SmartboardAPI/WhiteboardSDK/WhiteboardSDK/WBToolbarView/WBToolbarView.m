//
//  WBToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBToolbarView.h"
#import "WBCanvasToolbarView.h"
#import "WBBottomRightToolbarView.h"
#import <QuartzCore/QuartzCore.h>

#define kCanvasToolBarTag 777
#define kBottomRightToolBarTag kCanvasToolBarTag+1

@implementation WBToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.layer.cornerRadius = 5;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
        
        float leftMargin = 0;
        float bottomRightToolbarWidth = 156;
        WBCanvasToolbarView *canvasToolbarView = [[WBCanvasToolbarView alloc] initWithFrame:CGRectMake(leftMargin, 0,
                                                                                                       frame.size.width-bottomRightToolbarWidth,
                                                                                                       frame.size.height)];
        canvasToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        canvasToolbarView.delegate = self;
        canvasToolbarView.tag = kCanvasToolBarTag;
        [self addSubview:canvasToolbarView];
        
        float x = canvasToolbarView.frame.origin.x + canvasToolbarView.frame.size.width;
        WBBottomRightToolbarView *bottomRightToolbarView = [[WBBottomRightToolbarView alloc] initWithFrame:CGRectMake(x, canvasToolbarView.frame.origin.y, self.frame.size.width - x, self.frame.size.height)];
        bottomRightToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        bottomRightToolbarView.tag = kBottomRightToolBarTag;
        [self addSubview:bottomRightToolbarView];
    }
    return self;
}

- (void)updateColor:(UIColor *)color {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) updateColor:color];
}

- (void)updateAlpha:(float)alpha {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) updateAlpha:alpha];
}

- (void)updatePointSize:(float)size {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) updatePointSize:size];
}

- (void)showColorSpectrum:(BOOL)show {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showColorSpectrum:from:)]) {
        [self.delegate showColorSpectrum:show from:self];
    }
}

- (void)selectHistoryColor {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectHistoryColor)]) {
        [self.delegate selectHistoryColor];
    }
}

- (void)monitorClosed {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) monitorClosed];
}

- (void)selectEraser:(BOOL)select {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) selectEraser:select];
}

@end
