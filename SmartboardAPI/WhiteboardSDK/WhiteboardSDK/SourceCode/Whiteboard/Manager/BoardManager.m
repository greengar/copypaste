//
//  BoardManager.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/4/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "BoardManager.h"
#import "HistoryManager.h"
#import "WBUtils.h"
#import "WBBoard.h"

static BoardManager *shareManager = nil;

@implementation BoardManager
@synthesize boardKeys = _boardKeys;
@synthesize boardContents = _boardContents;
@synthesize currentBoardUid = _currentBoardUid;

+ (BoardManager *)sharedManager {
    static BoardManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [BoardManager new]; });
    return sharedManager;
}

+ (NSString *)getBaseDocumentFolder {
    NSString *baseDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES) objectAtIndex:0];
    return [baseDir stringByAppendingPathComponent:@"Whiteboard/"];
}

+ (NSDictionary *)writeBoardToFile:(WBBoard *)board {
    NSString *folderPath = [BoardManager getBaseDocumentFolder];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"%@.hector", board.uid]];
    NSDictionary *boardDict = [board exportBoardData];
	[boardDict writeToFile:filePath atomically:NO];
    return boardDict;
}

+ (WBBoard *)readBoardFromFileWithUid:(NSString *)uid {
    THROW_EXCEPTION_TYPE(UnimplementedException);
    NSString *folderPath = [BoardManager getBaseDocumentFolder];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"%@.hector", uid]];
    NSDictionary *boardDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    WBBoard *board = [[WBBoard alloc] init];
    [board updateWithDataForBoard:boardDict withBlock:^(BOOL succeed, NSError *error) {}];
    return board;
}

+ (NSDictionary *)exportBoardToData:(WBBoard *)board {
    return nil;
}

+ (WBBoard *)importDataToCreateBoard:(NSDictionary *)dict {
    return nil;
}

+ (WBBoard *)loadBoardWithUid:(NSString *)uid {
    return [[[BoardManager sharedManager] boardContents] objectForKey:uid];
}

+ (WBBoard *)loadBoardWithName:(NSString *)name {
    for (NSString *uid in [[BoardManager sharedManager] boardKeys]) {
        WBBoard *board = [[[BoardManager sharedManager] boardContents] objectForKey:uid];
        if ([[board name] isEqualToString:name]) {
            return board;
        }
    }
    return nil;
}

- (void)createANewBoard:(WBBoard *)board {
    if (![self.boardContents objectForKey:board.uid]) {
        [self.boardKeys addObject:board.uid];
        [self.boardContents setObject:board forKey:board.uid];
    }
    self.currentBoardUid = board.uid;
}

- (id) init {
    self = [super init];
    if (self) {
        self.boardKeys = [NSMutableArray new];
        self.boardContents = [NSMutableDictionary new];
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
