//
//  HistoryElementTextChanged.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTextChanged.h"
#import "TextElement.h"

@implementation HistoryElementTextChanged
@synthesize originalText = _originalText;
@synthesize changedText = _changedText;

- (id)init {
    if (self = [super init]) {
        self.name = @"Change Text";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [((TextElement *) self.element) setText:self.changedText];
        [self.element restore];
    } else {
        [((TextElement *) self.element) setText:self.originalText];
        [self.element restore];
    }
}

- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"HistoryElementTextChanged" forKey:@"history_type"];
    [dict setObject:self.originalText forKey:@"history_origin_text"];
    [dict setObject:self.changedText forKey:@"history_changed_text"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)historyData forPage:(WBPage *)page {
    [super loadFromData:historyData forPage:page];
    self.originalText = [historyData objectForKey:@"history_origin_text"];
    self.changedText = [historyData objectForKey:@"history_changed_text"];
    self.active = [[historyData objectForKey:@"history_active"] boolValue];
}

@end
