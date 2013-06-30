//
//  MultiStrokePaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "MultiStrokePaintingCmd.h"
#import "MainPaintingView.h"
#import "WBBaseElement.h"

@implementation MultiStrokePaintingCmd
@synthesize strokeArray = _strokeArray;

- (id)init {
    self = [super init];
    if (self) {
        self.strokeArray = [NSMutableArray new];
    }
    return self;
}

- (void)doPaintingAction {
    for (int i = 0; i < [self.strokeArray count]; i++) {
        StrokePaintingCmd *cmd = [self.strokeArray objectAtIndex:i];
        [cmd doPaintingAction];
    }
}

- (NSMutableDictionary *)saveToDataWithElementUid:(NSString *)elementUid
                                          pageUid:(NSString *)pageUid
                                       historyUid:(NSString *)historyUid {
    NSMutableDictionary *dict = [super saveToDataWithElementUid:elementUid pageUid:pageUid historyUid:historyUid];
    [dict setObject:@"MultiStrokePaintingCmd" forKey:@"paint_cmd_type"];
    
    if ([self.strokeArray count]) {
        NSMutableDictionary *strokeDicts = [NSMutableDictionary dictionaryWithCapacity:[self.strokeArray count]];
        for (int i = 0; i < [self.strokeArray count]; i++) {
            StrokePaintingCmd *cmd = [self.strokeArray objectAtIndex:i];
            NSMutableDictionary *cmdDict = [cmd saveToDataWithElementUid:elementUid pageUid:pageUid historyUid:historyUid];
            [strokeDicts setObject:cmdDict forKey:cmd.uid];
        }
        [dict setObject:strokeDicts forKey:@"paint_multi_stroke_array"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)loadFromData:(NSDictionary *)paintingCmdData forElement:(WBBaseElement *)element {
    [super loadFromData:paintingCmdData forElement:element];
    [self setDrawingView:((MainPaintingView *) [element contentView])];
    
    NSDictionary *multiStrokesData = [paintingCmdData objectForKey:@"paint_multi_stroke_array"];
    for (NSString *singlePaintUid in multiStrokesData) {
        NSDictionary *singlePaintCmdData = [multiStrokesData objectForKey:singlePaintUid];
        StrokePaintingCmd *singlePaintCmd = [[StrokePaintingCmd alloc] init];
        [singlePaintCmd loadFromData:singlePaintCmdData forElement:element];
        [self.strokeArray addObject:singlePaintCmd];
    }
}

- (void)dealloc {
    self.drawingView = nil;
}

@end
