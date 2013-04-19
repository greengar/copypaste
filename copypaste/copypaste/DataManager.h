//
//  DataManager.h
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPUser.h"
#import "GSSAuthenticationManager.h"

@interface DataManager : NSObject

+ (DataManager *) sharedManager;
+ (BOOL) isAuthenticated;
- (NSObject *) getThingsFromClipboard;

@property (nonatomic, retain) CPUser *myUser;
@property (nonatomic, retain) NSMutableArray *nearByUserList;
@property (nonatomic, retain) NSMutableArray *recentUserList;

@end
