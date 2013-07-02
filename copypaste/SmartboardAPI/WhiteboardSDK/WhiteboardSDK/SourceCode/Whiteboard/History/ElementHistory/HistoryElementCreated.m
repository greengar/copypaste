//
//  HistoryElementCreated.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCreated.h"
#import "UIColor+GSString.h"
#import "WBPage.h"

@implementation HistoryElementCreated
@synthesize defaultFrame = _defaultFrame;
@synthesize defaultTransform = _defaultTransform;

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = @"Create Text Box";
    } else if ([element isKindOfClass:[GLCanvasElement class]]
               || [element isKindOfClass:[CGCanvasElement class]]) {
        self.name = @"Start Drawing";
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = @"Add Image";
    } else if ([element isKindOfClass:[BackgroundElement class]]) {
        self.name = @"Add Background";
    }
    self.defaultFrame = element.defaultFrame;
    self.defaultTransform = element.defaultTransform;
}

- (void)setActive:(BOOL)active {
    [super setActive:active];
    if (active) {
        [self.page restoreElement:self.element];
    } else {
        [self.page removeElement:self.element];
    }
}

- (NSDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:@"HistoryElementCreated" forKey:@"history_type"];
    NSMutableDictionary *elementDict = [self.element saveToData];
    for (NSString *key in [elementDict allKeys]) {
        NSObject *object = [elementDict objectForKey:key];
        [dict setObject:object forKey:key];
    }
    return dict;
}

- (void)loadFromData:(NSDictionary *)historyData forPage:(WBPage *)page {
    [super loadFromData:historyData];
    NSString *elementType = [historyData objectForKey:@"element_type"];
    CGRect elementRect = CGRectFromString([historyData objectForKey:@"element_default_frame"]);
    WBBaseElement *element;
    if ([elementType isEqualToString:@"TextElement"]) {
        element = [[TextElement alloc] initWithFrame:elementRect];
    } else if ([elementType isEqualToString:@"GLCanvasElement"]) {
        element = [[GLCanvasElement alloc] initWithFrame:elementRect];
    } else if ([elementType isEqualToString:@"ImageElement"]) {
        element = [[ImageElement alloc] initWithFrame:elementRect];
    } else {
        element = [[WBBaseElement alloc] initWithFrame:elementRect];
    }
    
    [element loadFromData:historyData];
    [page addSubview:element];
    [element setDelegate:page];
    
    [self setPage:page];
    [self setElement:element];
    [self setActive:[[historyData objectForKey:@"history_active"] boolValue]];
}

@end
