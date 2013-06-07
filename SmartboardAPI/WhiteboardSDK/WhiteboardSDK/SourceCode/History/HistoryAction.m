//
//  HistoryAction.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryAction.h"

@implementation HistoryAction
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize active = _active;

- (id)init {
    if (self = [super init]) {
        self.active = YES;
    }
    return self;
}

@end
