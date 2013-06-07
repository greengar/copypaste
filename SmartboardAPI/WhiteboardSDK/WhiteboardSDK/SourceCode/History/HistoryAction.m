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
        self.date = [NSDate date];
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.active = YES;
        self.name = name;
        self.date = [NSDate date];
    }
    return self;
}

@end
