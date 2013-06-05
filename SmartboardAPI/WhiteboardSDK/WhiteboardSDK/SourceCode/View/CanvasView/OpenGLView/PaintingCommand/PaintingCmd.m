//
//  PaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "PaintingCmd.h"
#import "WBUtils.h"

@implementation PaintingCmd
@synthesize uid = _uid;
@synthesize drawingView = _drawingView;
@synthesize layerIndex = _layerIndex;

- (id)init {
    if (self = [super init]) {
        self.uid = [WBUtils stringFromDate:[NSDate date]];
    }
    return self;
}

- (void)doPaintingAction {
    
}

@end
