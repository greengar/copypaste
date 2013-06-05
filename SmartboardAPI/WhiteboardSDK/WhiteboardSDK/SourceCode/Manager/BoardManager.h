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

+ (BoardManager *) sharedManager;
+ (NSString *)getBaseDocumentFolder;
+ (BOOL)writeBoardToFile:(WBBoard *)board;
+ (WBBoard *)loadBoardWithUid:(NSString *)uid;

@end
