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
#import "HistoryElementCanvasDraw.h"
#import "HistoryElementTransform.h"

#define kHistoryMaxBuffer 50

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

- (void)addAction:(HistoryAction *)action forPage:(WBPage *)page {
    // Get the history for that page
    NSMutableArray *historyForPage = [self.historyPool objectForKey:page.uid];
    if (!historyForPage) {
        historyForPage = [NSMutableArray new];
        [self.historyPool setObject:historyForPage forKey:page.uid];
    }
    
    // Remove all deactivated actions
    NSMutableArray *toRemovePool = [NSMutableArray new];
    for (HistoryAction *action in historyForPage) {
        if ([action active] == NO) {
            [toRemovePool addObject:action];
        }
    }
    [historyForPage removeObjectsInArray:toRemovePool];
    
    // If reach the limit, remove the first action
    if ([historyForPage count] > kHistoryMaxBuffer) {
        [historyForPage removeObjectAtIndex:0];
    }
    
    // Add the new action
    [historyForPage addObject:action];

    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
        [self.delegate updateHistoryView];
    }
}

- (void)activateAction:(HistoryAction *)action forPage:(WBPage *)page {
    // Get the history for that page
    NSMutableArray *historyForPage = [self.historyPool objectForKey:page.uid];
    
    // Activate all actions before this action
    NSInteger index = [historyForPage indexOfObject:action];
    if (index != NSNotFound) {
        for (int i = 0; i <= index; i++) {
            HistoryAction *action = [historyForPage objectAtIndex:i];
            if (![action active]) {
                [action setActive:YES];
            }
        }
        
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateHistoryView)]) {
            [self.delegate updateHistoryView];
        }
    }
}

- (void)deactivateAction:(HistoryAction *)action forPage:(WBPage *)page {
    // Get the history for that page
    NSMutableArray *historyForPage = [self.historyPool objectForKey:page.uid];

    // Deactivate all actions after this action
    NSInteger index = [historyForPage indexOfObject:action];
    if (index != NSNotFound) {
        for (int i = [historyForPage count]-1; i >= index; i--) {
            HistoryAction *action = [historyForPage objectAtIndex:i];
            if ([action active]) {
                [action setActive:NO];
            }
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

#pragma mark - Helpers
- (void)addActionCreateElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementCreated *action = [[HistoryElementCreated alloc] init];
    [action setPage:page];
    [action setElement:element];
    [self addAction:action forPage:page];
}

- (void)addActionDeleteElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementDeleted *action = [[HistoryElementDeleted alloc] init];
    [action setPage:page];
    [action setElement:element];
    [self addAction:action forPage:page];
    [self activateAction:action forPage:page];
}

- (NSString *)addActionTransformElement:(WBBaseElement *)element
                               withName:(NSString *)name
                    withOriginTransform:(CGAffineTransform)transform
                                forPage:(WBPage *)page {
    // Get the history for that page
    NSMutableArray *historyForPage = [self.historyPool objectForKey:page.uid];
    
    // Update all transform actions that are not completed before this action
    for (HistoryElement *action in historyForPage) {
        if ([action isKindOfClass:[HistoryElementTransform class]]
            && [action.element.uid isEqualToString:element.uid]
            && !((HistoryElementTransform *) action).isFinished) {
            [((HistoryElementTransform *) action) setChangedTransform:transform];
        }
    }
    
    HistoryElementTransform *action = [[HistoryElementTransform alloc] initWithName:name];
    [action setElement:element];
    [action setOriginalTransform:transform];
    [self addAction:action forPage:page];
    return [action uid];
}

- (void)updateTransformElementWithId:(NSString *)uid
                withChangedTransform:(CGAffineTransform)transform
                             forPage:(WBPage *)page {
    // Get the history for that page
    NSMutableArray *historyForPage = [self.historyPool objectForKey:page.uid];
    
    // Update the desired transform action
    for (HistoryElement *action in historyForPage) {
        if ([action.uid isEqualToString:uid]
            && [action isKindOfClass:[HistoryElementTransform class]]
            && !((HistoryElementTransform *) action).isFinished) {
            [((HistoryElementTransform *) action) setChangedTransform:transform];
        }
    }
}

- (void)addActionBrushElement:(WBBaseElement *)element forPage:(WBPage *)page {
    HistoryElementCanvasDraw *action = [[HistoryElementCanvasDraw alloc] init];
    [action setElement:element];
    [self addAction:action forPage:page];
}

- (void)addActionTextContentChangedElement:(TextElement *)element
                            withOriginText:(NSString *)text1
                           withChangedText:(NSString *)text2
                                   forPage:(WBPage *)page {
    if (![text1 isEqualToString:text2]) {
        HistoryElementTextChanged *action = [[HistoryElementTextChanged alloc] init];
        [action setElement:element];
        [action setOriginalText:text1];
        [action setChangedText:text2];
        [self addAction:action forPage:page];
    }
}

- (void)addActionTextFontChangedElement:(TextElement *)element
                     withOriginFontName:(NSString *)name1 fontSize:(int)size1
                    withChangedFontName:(NSString *)name2 fontSize:(int)size2
                                forPage:(WBPage *)page {
    if (![name1 isEqualToString:name2] || size1 != size2) {
        HistoryElementTextFontChanged *action = [[HistoryElementTextFontChanged alloc] init];
        [action setElement:element];
        [action setOriginalFontName:name1];
        [action setOriginalFontSize:size1];
        [action setChangedFontName:name2];
        [action setChangedFontSize:size2];
        [self addAction:action forPage:page];
    }
}

- (void)addActionTextColorChangedElement:(TextElement *)element
                         withOriginColor:(UIColor *)color1 x:(float)x1 y:(float)y1
                        withChangedColor:(UIColor *)color2 x:(float)x2 y:(float)y2
                                 forPage:(WBPage *)page {
    if (x1 != x2 || y1 != y2) {
        HistoryElementTextColorChanged *action = [[HistoryElementTextColorChanged alloc] init];
        [action setElement:element];
        [action setOriginalColor:color1];
        [action setOriginalColorX:x1];
        [action setOriginalColorY:y1];
        [action setChangedColor:color2];
        [action setChangedColorX:x2];
        [action setChangedColorY:y2];
        [self addAction:action forPage:page];
    }
}

- (id) init {
    self = [super init];
    if (self) {
        self.historyPool = [NSMutableDictionary new];
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
