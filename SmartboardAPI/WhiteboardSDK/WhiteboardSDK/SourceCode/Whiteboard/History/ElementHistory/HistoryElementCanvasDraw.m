//
//  HistoryElementCanvasDraw.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCanvasDraw.h"

@implementation HistoryElementCanvasDraw
@synthesize paintingCommand = _paintingCommand;

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
        [[paintingView undoSequenceArray] addObject:self.paintingCommand];
        [paintingView reloadView];
    } else {
        [paintingView undoStroke];
    }
}

- (NSDictionary *)backupToData {
    NSMutableDictionary *dict = [super backupToData];
    [dict setObject:@"HistoryElementCanvasDraw" forKey:@"history_type"];
    [dict setObject:[self.paintingCommand saveToDict] forKey:@"history_painting"];
    return dict;
}


@end
