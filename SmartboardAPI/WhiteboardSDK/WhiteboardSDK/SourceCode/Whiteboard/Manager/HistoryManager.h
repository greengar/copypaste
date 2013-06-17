//
//  HistoryManager.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/6/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryAction.h"

@class WBBaseElement;
@class TextElement;
@class WBPage;

@protocol HistoryManagerDelegate
- (void)updateHistoryView;
@end

@interface HistoryManager : NSObject

+ (HistoryManager *)sharedManager;

- (void)addAction:(HistoryAction *)action;
- (void)activateAction:(HistoryAction *)action;
- (void)deactivateAction:(HistoryAction *)action;
- (void)finishAction;

// Helper
- (void)addActionCreateElement:(WBBaseElement *)element forPage:(WBPage *)page;
- (void)addActionDeleteElement:(WBBaseElement *)element forPage:(WBPage *)page;
- (NSString *)addActionTransformElement:(WBBaseElement *)element
                               withName:(NSString *)name
                    withOriginTransform:(CGAffineTransform)transform;
- (void)updateTransformElementWithId:(NSString *)uid
                withChangedTransform:(CGAffineTransform)transform;
- (void)addActionTextContentChangedElement:(TextElement *)element
                            withOriginText:(NSString *)text1
                           withChangedText:(NSString *)text2;
- (void)addActionTextFontChangedElement:(TextElement *)element
                     withOriginFontName:(NSString *)name1 fontSize:(int)size1
                    withChangedFontName:(NSString *)name2 fontSize:(int)size2;
- (void)addActionTextColorChangedElement:(TextElement *)element
                         withOriginColor:(UIColor *)color1 x:(float)x1 y:(float)y1
                        withChangedColor:(UIColor *)color2 x:(float)x2 y:(float)y2;

- (void)clearHistoryPool;

@property (nonatomic, strong) NSMutableArray *historyPool;
@property (nonatomic, strong) HistoryAction *currentAction;
@property (nonatomic, assign) id<HistoryManagerDelegate> delegate;

@end
