//
//  HistoryElementCanvasDraw.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCanvasDraw.h"

@implementation HistoryElementCanvasDraw

- (id)init {
    if (self = [super init]) {
        self.name = @"Brush";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    GLCanvasElement *canvasElement = (GLCanvasElement *) self.element;
    MainPaintingView *paintingView = (MainPaintingView *) [canvasElement contentView];
    if (active) {
        [paintingView redoStroke];
    } else {
        [paintingView undoStroke];
    }
}


@end
