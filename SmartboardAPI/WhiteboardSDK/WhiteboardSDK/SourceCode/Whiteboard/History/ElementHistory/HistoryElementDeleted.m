//
//  HistoryElementDeleted.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementDeleted.h"

@implementation HistoryElementDeleted

@synthesize page = _page;

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = @"Remove Text";
    } else if ([element isKindOfClass:[GLCanvasElement class]]
               || [element isKindOfClass:[CGCanvasElement class]]) {
        self.name = @"Remove Brush";
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = @"Remove Image";
    } else if ([element isKindOfClass:[BackgroundElement class]]) {
        self.name = @"Remove Background";
    }
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.page removeElement:self.element];
    } else {
        [self.page restoreElement:self.element];
    }
}

- (NSDictionary *)backupToData {
    NSMutableDictionary *dict = [super backupToData];
    [dict setObject:@"HistoryElementDeleted" forKey:@"history_type"];
    return dict;
}

@end
