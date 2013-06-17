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
@synthesize isFinished = _isFinished;

- (void)setChangedTransform:(CGAffineTransform)changedTransform {
    _changedTransform = changedTransform;
    self.isFinished = YES;
}

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = [NSString stringWithFormat:@"%@ Text", self.name];
    } else if ([element isKindOfClass:[GLCanvasElement class]]
               || [element isKindOfClass:[CGCanvasElement class]]) {
        self.name = [NSString stringWithFormat:@"%@ Brush", self.name];
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = [NSString stringWithFormat:@"%@ Image", self.name];
    } else if ([element isKindOfClass:[BackgroundElement class]]) {
        self.name = [NSString stringWithFormat:@"%@ Background", self.name];
    }
}


- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.element setTransform:self.changedTransform];
    } else {
        [self.element setTransform:self.originalTransform];
    }
}

@end
