//
//  HistoryElementCreated.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCreated.h"

@implementation HistoryElementCreated
@synthesize page = _page;

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = @"Type Text";
    } else if ([element isKindOfClass:[GLCanvasElement class]]
               || [element isKindOfClass:[CGCanvasElement class]]) {
        self.name = @"Brush";
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = @"Add Image";
    } else if ([element isKindOfClass:[BackgroundElement class]]) {
        self.name = @"Add Background";
    }
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.page restoreElement:self.element];
    } else {
        [self.page removeElement:self.element];
    }
}

- (NSDictionary *)backupToData {
    NSMutableDictionary *dict = [super backupToData];
    [dict setObject:@"HistoryElementCreated" forKey:@"history_type"];
    [dict setObject:NSStringFromCGRect(self.element.defaultFrame) forKey:@"history_default_frame"];
    [dict setObject:NSStringFromCGAffineTransform(self.element.defaultTransform) forKey:@"history_default_transform"];
    [dict setObject:NSStringFromCGAffineTransform(self.element.currentTransform) forKey:@"history_current_transform"];
    return dict;
}

@end
