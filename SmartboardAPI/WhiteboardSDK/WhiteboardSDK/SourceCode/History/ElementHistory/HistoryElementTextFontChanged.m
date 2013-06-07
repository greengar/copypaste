//
//  HistoryElementTextFontChanged.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/7/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTextFontChanged.h"
#import "TextElement.h"

@implementation HistoryElementTextFontChanged
@synthesize originalFontName = _originalFontName;
@synthesize originalFontSize = _originalFontSize;
@synthesize changedFontName = _changedFontName;
@synthesize changedFontSize = _changedFontSize;

- (id)init {
    if (self = [super init]) {
        self.name = @"Font Changed";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [((TextElement *) self.element) updateWithFontName:self.changedFontName
                                                      size:self.changedFontSize];
    } else {
        [((TextElement *) self.element) updateWithFontName:self.originalFontName
                                                      size:self.originalFontSize];
    }
}

@end
