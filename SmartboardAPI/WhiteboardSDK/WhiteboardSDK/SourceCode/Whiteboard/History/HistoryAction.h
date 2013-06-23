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

@interface HistoryAction : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL active;
@property (nonatomic, assign) WBBoard *board;

- (id)initWithName:(NSString *)name;

- (NSDictionary *)backupToData;
- (void)restoreFromData:(NSDictionary *)data;

@end
