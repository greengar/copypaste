//
//  HistoryElement.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryElement.h"
#import "WBPage.h"

@implementation HistoryElement
@synthesize element = _element;

- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [super saveToData];
    [dict setObject:self.element.uid forKey:@"element_uid"];
    [dict setObject:((WBPage *) self.element.superview).uid forKey:@"page_uid"]; // Cheat, get the page uid to make the parse faster
    return dict;
}

- (void)loadFromData:(NSDictionary *)data {
    [super loadFromData:data];
}

- (void)loadFromData:(NSDictionary *)data forBoard:(WBBoard *)board {
    [super loadFromData:data forBoard:board];
}

- (void)loadFromData:(NSDictionary *)data forPage:(WBPage *)page {
    [super loadFromData:data forPage:page];
}

@end
