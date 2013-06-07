//
//  HistoryManager.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "HistoryManager.h"
#import "HistoryElementCreated.h"
#import "HistoryElementDeleted.h"

#define kHistoryMaxBuffer 10

static HistoryManager *shareManager = nil;

@interface HistoryManager()

@end

@implementation HistoryManager
@synthesize delegate = _delegate;
@synthesize historyPool = _historyPool;
@synthesize currentAction = _currentAction;

+ (HistoryManager *)sharedManager {
    static HistoryManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [HistoryManager new]; });
    return sharedManager;
}

- (void)addAction:(HistoryAction *)action {
    self.currentAction = action;
    [self clearRedoPool];
    if ([self.historyPool count] > kHistoryMaxBuffer) {
        [self.historyPool removeObjectAtIndex:0];
    }
    [self.historyPool addObject:action];

    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
        [self.delegate updateHistoryView];
    }
}

- (void)activateAction:(HistoryAction *)action {
    NSInteger index = [self.historyPool indexOfObject:action];
    if (index != NSNotFound) {
        for (int i = 0; i <= index; i++) {
            HistoryAction *action = [self.historyPool objectAtIndex:i];
            [action setActive:YES];
        }
        
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
            [self.delegate updateHistoryView];
        }
    }
}

- (void)deactivateAction:(HistoryAction *)action {
    NSInteger index = [self.historyPool indexOfObject:action];
    if (index != NSNotFound) {
        for (int i = [self.historyPool count]-1; i >= index; i--) {
            HistoryAction *action = [self.historyPool objectAtIndex:i];
            [action setActive:NO];
        }
        
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
            [self.delegate updateHistoryView];
        }
    }
}

- (void)finishAction {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
        [self.delegate updateHistoryView];
    }
}

- (void)clearHistoryPoolWithBlock:(GSResultBlock)block {
    [self.historyPool removeAllObjects];
}

- (void)clearRedoPool {
    NSMutableArray *toRemovePool = [NSMutableArray new];
    for (HistoryAction *action in self.historyPool) {
        if ([action active] == NO) {
            [toRemovePool addObject:action];
        }
    }
    [self.historyPool removeObjectsInArray:toRemovePool];
}

#pragma mark - Helpers
- (void)addActionCreateElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementCreated *action = [[HistoryElementCreated alloc] init];
    [action setPage:page];
    [action setElement:element];
    [[HistoryManager sharedManager] addAction:action];
}

- (void)addActionDeleteElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementDeleted *action = [[HistoryElementDeleted alloc] init];
    [action setPage:page];
    [action setElement:element];
    [[HistoryManager sharedManager] addAction:action];
    [[HistoryManager sharedManager] activateAction:action];
}

- (id) init {
    self = [super init];
    if (self) {
        self.historyPool = [NSMutableArray new];
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
