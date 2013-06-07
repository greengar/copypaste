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

- (id)init {
    if (self = [super init]) {
        self.name = @"Deleted";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.page removeElement:self.element];
    } else {
        [self.page addElement:self.element];
    }
}

@end
