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

- (id)init {
    if (self = [super init]) {
        self.name = @"Created";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.page addElement:self.element];
    } else {
        [self.page removeElement:self.element];
    }
}

@end
