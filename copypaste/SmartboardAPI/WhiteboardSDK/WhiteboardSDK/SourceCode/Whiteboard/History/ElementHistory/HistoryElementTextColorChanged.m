//
//  HistoryElementTextColorChanged.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/7/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementTextColorChanged.h"
#import "TextElement.h"
#import "UIColor+GSString.h"

@implementation HistoryElementTextColorChanged
@synthesize originalColor = _originalColor;
@synthesize originalColorX = _originalColorX;
@synthesize originalColorY = _originalColorY;
@synthesize changedColor = _changedColor;
@synthesize changedColorX = _changedColorX;
@synthesize changedColorY = _changedColorY;

- (id)init {
    if (self = [super init]) {
        self.name = @"Change Text Color";
    }
    return self;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [((TextElement *) self.element) updateWithColor:self.changedColor
                                                      x:self.changedColorX
                                                      y:self.changedColorY];
    } else {
        [((TextElement *) self.element) updateWithColor:self.originalColor
                                                      x:self.originalColorX
                                                      y:self.originalColorY];
    }
}

- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"HistoryElementTextColorChanged" forKey:@"history_type"];
    [dict setObject:[self.originalColor gsString] forKey:@"history_origin_color"];
    [dict setObject:[self.changedColor gsString] forKey:@"history_changed_color"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)data forPage:(WBPage *)page {
    [super loadFromData:data forPage:page];
    self.originalColor = [UIColor gsColorFromString:[data objectForKey:@"history_origin_color"]];
    self.changedColor = [UIColor gsColorFromString:[data objectForKey:@"history_changed_color"]];
    self.active = [[data objectForKey:@"history_active"] boolValue];
}

@end