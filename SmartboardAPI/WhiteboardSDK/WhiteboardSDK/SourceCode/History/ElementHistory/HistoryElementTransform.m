//
//  HistoryElementTransform.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTransform.h"
#import "TextElement.h"
#import "CanvasElement.h"
#import "ImageElement.h"

@implementation HistoryElementTransform
@synthesize originalTransform = _originalTransform;
@synthesize changedTransform = _changedTransform;

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = [NSString stringWithFormat:@"Text %@", self.name];
    } else if ([element isKindOfClass:[CanvasElement class]]) {
        self.name = [NSString stringWithFormat:@"Canvas %@", self.name];
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = [NSString stringWithFormat:@"Image %@", self.name];
    } else {
        self.name = [NSString stringWithFormat:@"View %@", self.name];
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
