//
//  PaintingCmd.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "PaintingCmd.h"
#import "SDUtils.h"

@implementation PaintingCmd
@synthesize uid = _uid;
@synthesize drawingView = _drawingView;
@synthesize layerIndex = _layerIndex;

- (id)init {
    if (self = [super init]) {
        self.uid = [SDUtils stringFromDate:[NSDate date]];
    }
    return self;
}

- (void)doPaintingAction {
    
}

@end
