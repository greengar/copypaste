//
//  MultiStrokePaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "MultiStrokePaintingCmd.h"

@implementation MultiStrokePaintingCmd
@synthesize strokeArray = _strokeArray;

- (id)init {
    self = [super init];
    if (self) {
        self.strokeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)doPaintingAction {
    for (int i = 0; i < [self.strokeArray count]; i++) {
        StrokePaintingCmd *cmd = [self.strokeArray objectAtIndex:i];
        [cmd doPaintingAction];
    }
}

@end
