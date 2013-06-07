//
//  HistoryManager.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryAction.h"

@protocol HistoryManagerDelegate
- (void)updateHistoryView;
@end

@interface HistoryManager : NSObject

+ (HistoryManager *)sharedManager;

- (void)addAction:(HistoryAction *)action;
- (void)activateAction:(HistoryAction *)action;
- (void)deactivateAction:(HistoryAction *)action;
- (void)finishAction;

- (void)clearHistoryPoolWithBlock:(GSResultBlock)block;

@property (nonatomic, strong) NSMutableArray *historyPool;
@property (nonatomic, strong) HistoryAction *currentAction;
@property (nonatomic, assign) id<HistoryManagerDelegate> delegate;

@end