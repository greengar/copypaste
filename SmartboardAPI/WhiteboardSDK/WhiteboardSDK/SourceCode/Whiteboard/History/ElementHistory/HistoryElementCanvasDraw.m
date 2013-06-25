//
//  HistoryElementCanvasDraw.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCanvasDraw.h"
#import "MultiStrokePaintingCmd.h"

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

- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"HistoryElementCanvasDraw" forKey:@"history_type"];
    [dict setObject:[self.paintingCommand saveToData] forKey:@"history_painting"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)historyData forPage:(WBPage *)page {
    [super loadFromData:historyData];
    
    NSDictionary *paintingCmdData = [historyData objectForKey:@"history_painting"];
    
    NSString *paintingType = [paintingCmdData objectForKey:@"paint_cmd_type"];
    if ([paintingType isEqualToString:@"MultiStrokePaintingCmd"]) {
        MultiStrokePaintingCmd *paintCmd = [[MultiStrokePaintingCmd alloc] init];
        [paintCmd loadFromData:paintingCmdData forElement:self.element];
        [self setPaintingCommand:paintCmd];
        [self setActive:[[historyData objectForKey:@"history_active"] boolValue]];
    } else if ([paintingType isEqualToString:@"StrokePaintingCmd"]) {
        StrokePaintingCmd *paintCmd = [[StrokePaintingCmd alloc] init];
        [paintCmd loadFromData:paintingCmdData forElement:self.element];
        [self setPaintingCommand:paintCmd];
        [self setActive:[[historyData objectForKey:@"history_active"] boolValue]];
    }
}

@end
