//
//  HistoryAction.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryAction.h"
#import "WBUtils.h"

@implementation HistoryAction
@synthesize uid = _uid;
@synthesize name = _name;
@synthesize active = _active;
@synthesize date = _date;
@synthesize board = _board;

- (id)init {
    if (self = [super init]) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"H_"];
        self.active = YES;
        self.name = @"";
        self.date = [NSDate date];
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"H_"];
        self.active = YES;
        self.name = name;
        self.date = [NSDate date];
    }
    return self;
}

- (NSMutableDictionary *)backupToData {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"history_uid" : self.uid,
                                                          @"history_name" : self.name,
                                                        @"history_active" : [NSNumber numberWithBool:self.active],
                                                          @"history_date" : [WBUtils stringFromDate:self.date]}];
}

- (void)restoreFromData:(NSDictionary *)data {
    self.name = [data objectForKey:@"history_name"];
    self.active = [[data objectForKey:@"history_active"] boolValue];
    self.date = [WBUtils dateFromString:[data objectForKey:@"history_date"]];
}

@end
