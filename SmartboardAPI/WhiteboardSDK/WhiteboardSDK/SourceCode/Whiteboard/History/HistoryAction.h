//
//  HistoryAction.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUtils.h"

@class WBBoard;
@class WBPage;

@interface HistoryAction : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL active;
@property (nonatomic, assign) WBBoard *board;

- (id)initWithName:(NSString *)name;

- (NSMutableDictionary *)saveToData;
- (void)loadFromData:(NSDictionary *)data;
- (void)loadFromData:(NSDictionary *)data forBoard:(WBBoard *)board;
- (void)loadFromData:(NSDictionary *)data forPage:(WBPage *)page;

@end
