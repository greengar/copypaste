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
        float bottomRightToolbarWidth = [WBBottomRightToolbarView preferredSize].width;
        WBCanvasToolbarView *canvasToolbarView = [[WBCanvasToolbarView alloc] initWithFrame:CGRectMake(leftMargin, 0,
                                                                                                       frame.size.width-bottomRightToolbarWidth,
                                                                                                       frame.size.height)];
        canvasToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        canvasToolbarView.delegate = self;
        canvasToolbarView.tag = kCanvasToolBarTag;
        [self addSubview:canvasToolbarView];
        
        float x = canvasToolbarView.frame.origin.x + canvasToolbarView.frame.size.width;
        WBBottomRightToolbarView *bottomRightToolbarView = [[WBBottomRightToolbarView alloc] initWithFrame:CGRectMake(x, canvasToolbarView.frame.origin.y, [WBBottomRightToolbarView preferredSize].width, [WBBottomRightToolbarView preferredSize].height)];
        // self.frame.size.width - x, self.frame.size.height
        bottomRightToolbarView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        bottomRightToolbarView.delegate = self;
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

- (void)canvasButtonTapped {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(canvasButtonTappedFrom:)]) {
        [self.delegate canvasButtonTappedFrom:self];
    }
}

- (void)selectHistoryColor {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectHistoryColor)]) {
        [self.delegate selectHistoryColor];
    }
}

- (void)didShowMonitorView:(BOOL)success {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) didShowMonitorView:success];
}

- (void)didShowAddMoreView:(BOOL)success {
    [((WBBottomRightToolbarView *) [self viewWithTag:kBottomRightToolBarTag]) didShowAddMoreView:success];
}

- (void)selectCanvasMode:(CanvasMode)mode {
    [((WBCanvasToolbarView *) [self viewWithTag:kCanvasToolBarTag]) selectCanvasMode:mode];
}

- (void)didActivatedMove:(BOOL)success {
    [((WBBottomRightToolbarView *) [self viewWithTag:kBottomRightToolBarTag]) didActivatedMove:success];
}

- (void)addMoreButtonTapped {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addMoreButtonTappedFrom:)]) {
        [self.delegate addMoreButtonTappedFrom:self];
    }
}

- (void)moveButtonTapped {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(moveButtonTapped)]) {
        [self.delegate moveButtonTapped];
    }
}

@end
