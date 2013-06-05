//
//  BoardManager.h
//  TestSDSDK
//
//  Created by Hector Zhao on 6/4/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDBoard;

@interface BoardManager : NSObject

+ (BoardManager *) sharedManager;
+ (NSString *)getBaseDocumentFolder;
+ (BOOL)writeBoardToFile:(SDBoard *)board;
+ (SDBoard *)loadBoardWithUid:(NSString *)uid;

@end
