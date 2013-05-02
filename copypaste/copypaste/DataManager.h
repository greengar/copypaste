//
//  DataManager.h
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPMessage.h"
#import "CPUser.h"

@interface DataManager : NSObject

+ (DataManager *) sharedManager;
- (NSObject *) getThingsFromClipboard;
- (void)updateNearbyUsers:(NSArray *)nearbyList;
- (CPUser *)userById:(NSString *)uid;
- (void)getNumOfMessageFromUser:(CPUser *)fromUser toUser:(CPUser *)toUser;
- (void)pasteToUser:(CPUser *)user block:(GSResultBlock)block;
- (NSArray *)sortedAvailableUsersByLocation;
- (NSArray *)sortedAvailableUsersByName;

@property (nonatomic, strong) NSMutableArray *availableUsers;
@property (nonatomic, strong) NSMutableArray *receivedMessages;

@end
