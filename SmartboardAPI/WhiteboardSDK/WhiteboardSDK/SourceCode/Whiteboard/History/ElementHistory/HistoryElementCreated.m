//
//  HistoryElementCreated.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElementCreated.h"
#import "UIColor+GSString.h"

@implementation HistoryElementCreated
@synthesize page = _page;

- (void)setElement:(WBBaseElement *)element {
    [super setElement:element];
    if ([element isKindOfClass:[TextElement class]]) {
        self.name = @"Type Text";
    } else if ([element isKindOfClass:[GLCanvasElement class]]
               || [element isKindOfClass:[CGCanvasElement class]]) {
        self.name = @"Start Brush";
    } else if ([element isKindOfClass:[ImageElement class]]) {
        self.name = @"Add Image";
    } else if ([element isKindOfClass:[BackgroundElement class]]) {
        self.name = @"Add Background";
    }
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
    [dict setObject:NSStringFromCGRect(self.element.defaultFrame) forKey:@"history_default_frame"];
    [dict setObject:NSStringFromCGAffineTransform(self.element.defaultTransform) forKey:@"history_default_transform"];
    [dict setObject:NSStringFromCGAffineTransform(self.element.currentTransform) forKey:@"history_current_transform"];
    
    if ([self.element isKindOfClass:[TextElement class]]) {
        TextElement *element = (TextElement *) self.element;
        [dict setObject:@"TextElement" forKey:@"element_type"];
        [dict setObject:((UITextView *) element.contentView).text forKey:@"element_text"];
        [dict setObject:element.myFontName forKey:@"element_font_name"];
        [dict setObject:[NSNumber numberWithInt:element.myFontSize] forKey:@"element_font_size"];
        [dict setObject:[element.myColor gsString] forKey:@"element_font_color"];
    } else if ([self.element isKindOfClass:[GLCanvasElement class]]) {
        [dict setObject:@"GLCanvasElement" forKey:@"element_type"];
    } else if ([self.element isKindOfClass:[ImageElement class]]) {
        [dict setObject:@"ImageElement" forKey:@"element_type"];
    }
    
    return dict;
}

- (void)loadFromData:(NSDictionary *)historyData forPage:(WBPage *)page {
    [super loadFromData:historyData];
    NSString *elementType = [historyData objectForKey:@"element_type"];
    CGRect elementRect = CGRectFromString([historyData objectForKey:@"history_default_frame"]);
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
    
    [self setElement:element];
    [self setActive:[[historyData objectForKey:@"history_active"] boolValue]];
}

@end
