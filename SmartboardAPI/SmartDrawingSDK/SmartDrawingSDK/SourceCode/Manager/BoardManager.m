//
//  BoardManager.m
//  TestSDSDK
//
//  Created by Hector Zhao on 6/4/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "BoardManager.h"
#import "SDUtils.h"
#import "SDBoard.h"

static BoardManager *shareManager = nil;

@implementation BoardManager

+ (BoardManager *)sharedManager {
    static BoardManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [BoardManager new]; });
    return sharedManager;
}

+ (NSString *)getBaseDocumentFolder {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (BOOL)writeBoardToFile:(SDBoard *)board {
    NSString * filePath = [[BoardManager getBaseDocumentFolder] stringByAppendingPathComponent:board.uid];
	return [[board saveToDict] writeToFile:filePath atomically:NO];
}

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (shareManager == nil) {
            shareManager = [super allocWithZone:zone];
            return shareManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
