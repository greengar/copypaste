//
//  DataManager.h
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPUser.h"

@interface DataManager : NSObject

+ (DataManager *) sharedManager;
- (NSObject *) getThingsFromClipboard;
- (void)updateNearbyUsers:(NSArray *)nearbyList;

@property (nonatomic, retain) CPUser *myUser;
@property (nonatomic, retain) NSMutableArray *nearByUserList;
@property (nonatomic, retain) NSMutableArray *recentUserList;

@end
