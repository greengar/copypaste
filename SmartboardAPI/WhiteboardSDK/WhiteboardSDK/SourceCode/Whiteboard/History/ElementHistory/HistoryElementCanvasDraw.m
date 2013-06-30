//
//  HistoryElementCanvasDraw.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCanvasDraw.h"
#import "MultiStrokePaintingCmd.h"
#import "WBBaseElement.h"
#import "WBPage.h"

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
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [paintingView reloadView];
        });
        [self.element setIsFake:NO];
    } else {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [paintingView undoStroke];
        });
    }
}

- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"HistoryElementCanvasDraw" forKey:@"history_type"];
    [dict setObject:[self.paintingCommand saveToDataWithElementUid:self.element.uid
                                                           pageUid:self.page.uid
                                                        historyUid:self.uid]
             forKey:@"history_painting"];
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
        ((GLCanvasElement *)self.element).boundingRect = paintCmd.drawingView.previewAreaRect;
        
    } else if ([paintingType isEqualToString:@"StrokePaintingCmd"]) {
        StrokePaintingCmd *paintCmd = [[StrokePaintingCmd alloc] init];
        [paintCmd loadFromData:paintingCmdData forElement:self.element];
        [self setPaintingCommand:paintCmd];
        [self setActive:[[historyData objectForKey:@"history_active"] boolValue]];
        ((GLCanvasElement *)self.element).boundingRect = paintCmd.drawingView.previewAreaRect;
    }
}

@end
