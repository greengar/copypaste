//
//  HistoryElementTransform.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTransform.h"
#import "TextElement.h"
#import "GLCanvasElement.h"
#import "ImageElement.h"

@implementation HistoryElementTransform
@synthesize originalTransform = _originalTransform;
@synthesize changedTransform = _changedTransform;

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.element setTransform:self.changedTransform];
    } else {
        [self.element setTransform:self.originalTransform];
    }
}

@end
