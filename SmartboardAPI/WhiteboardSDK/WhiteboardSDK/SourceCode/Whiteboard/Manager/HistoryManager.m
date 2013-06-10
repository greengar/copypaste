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
#import "HistoryElementTextChanged.h"
#import "HistoryElementTextFontChanged.h"
#import "HistoryElementTextColorChanged.h"

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

- (void)clearHistoryPool {
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
    [self addAction:action];
}

- (void)addActionDeleteElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementDeleted *action = [[HistoryElementDeleted alloc] init];
    [action setPage:page];
    [action setElement:element];
    [self addAction:action];
    [self activateAction:action];
}

- (void)addActionTextContentChangedElement:(TextElement *)element
                            withOriginText:(NSString *)text1
                           withChangedText:(NSString *)text2 {
    if (![text1 isEqualToString:text2]) {
        HistoryElementTextChanged *action = [[HistoryElementTextChanged alloc] init];
        [action setElement:element];
        [action setOriginalText:text1];
        [action setChangedText:text2];
        [self addAction:action];
    }
}

- (void)addActionTextFontChangedElement:(TextElement *)element
                     withOriginFontName:(NSString *)name1 fontSize:(int)size1
                    withChangedFontName:(NSString *)name2 fontSize:(int)size2 {
    if (![name1 isEqualToString:name2] || size1 != size2) {
        HistoryElementTextFontChanged *action = [[HistoryElementTextFontChanged alloc] init];
        [action setElement:element];
        [action setOriginalFontName:name1];
        [action setOriginalFontSize:size1];
        [action setChangedFontName:name2];
        [action setChangedFontSize:size2];
        [self addAction:action];
        
        name1 = name2;
        size1 = size2;
    }
}

- (void)addActionTextColorChangedElement:(TextElement *)element
                         withOriginColor:(UIColor *)color1 x:(float)x1 y:(float)y1
                        withChangedColor:(UIColor *)color2 x:(float)x2 y:(float)y2 {
    if (x1 != x2 || y1 != y2) {
        HistoryElementTextColorChanged *action = [[HistoryElementTextColorChanged alloc] init];
        [action setElement:element];
        [action setOriginalColor:color1];
        [action setOriginalColorX:x1];
        [action setOriginalColorY:y1];
        [action setChangedColor:color2];
        [action setChangedColorX:x2];
        [action setChangedColorY:y2];
        [self addAction:action];
    }
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
