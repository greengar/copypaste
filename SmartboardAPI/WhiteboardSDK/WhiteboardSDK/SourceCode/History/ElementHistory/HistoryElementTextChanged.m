//
//  HistoryElementTextChanged.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTextChanged.h"
#import "TextElement.h"

@implementation HistoryElementTextChanged
@synthesize originalText = _originalText;
@synthesize changedText = _changedText;

- (id)init {
    if (self = [super init]) {
        self.name = @"Text Changed";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [((TextElement *) self.element) setText:self.originalText];
    } else {
        [((TextElement *) self.element) setText:self.changedText];
    }
}

@end
