//
//  HistoryElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"
#import "TextElement.h"
#import "CanvasElement.h"
#import "ImageElement.h"

@implementation HistoryElement
@synthesize element = _element;

- (void)setElement:(WBBaseElement *)element {
    _element = element;
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


@end
