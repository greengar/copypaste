//
//  BoardManager.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/4/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBBoard;

@interface BoardManager : NSObject

+ (BoardManager *)sharedManager;
+ (NSString *)getBaseDocumentFolder;

+ (NSDictionary *)writeBoardToFile:(WBBoard *)board;
+ (WBBoard *)readBoardFromFileWithUid:(NSString *)uid;

+ (NSDictionary *)exportBoardToData:(WBBoard *)board;
+ (WBBoard *)importDataToCreateBoard:(NSDictionary *)dict;

+ (WBBoard *)loadBoardWithUid:(NSString *)uid;
+ (WBBoard *)loadBoardWithName:(NSString *)name;
- (void)createANewBoard:(WBBoard *)board;

@property (nonatomic, strong) NSMutableArray *boardKeys;
@property (nonatomic, strong) NSMutableDictionary *boardContents;
@property (nonatomic, strong) NSString *currentBoardUid;

@end
