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
@class PaintingCmd;

@protocol HistoryManagerDelegate
- (void)updateHistoryView;
@end

@interface HistoryManager : NSObject

+ (HistoryManager *)sharedManager;

- (void)addAction:(HistoryAction *)action forPage:(WBPage *)page;
- (void)activateAction:(HistoryAction *)action forPage:(WBPage *)page;
- (void)deactivateAction:(HistoryAction *)action forPage:(WBPage *)page;
- (void)finishAction;

// Helper
- (void)addActionCreateElement:(WBBaseElement *)element forPage:(WBPage *)page withBlock:(WBSingleResultBlock)block;
- (void)addActionDeleteElement:(WBBaseElement *)element forPage:(WBPage *)page withBlock:(WBSingleResultBlock)block;

- (NSString *)addActionTransformElement:(WBBaseElement *)element
                               withName:(NSString *)name
                    withOriginTransform:(CGAffineTransform)transform
                                forPage:(WBPage *)page
                              withBlock:(WBArrayResultBlock)block;

- (void)updateTransformElementWithId:(NSString *)uid
                withChangedTransform:(CGAffineTransform)transform
                             forPage:(WBPage *)page
                           withBlock:(WBArrayResultBlock)block;

- (NSString *)addActionBrushElement:(WBBaseElement *)element
                            forPage:(WBPage *)page
                withPaintingCommand:(PaintingCmd *)paintingCmd
                          withBlock:(WBSingleResultBlock)block;

- (void)updateActionBrushElementWithId:(NSString *)uid
                   withPaintingCommand:(PaintingCmd *)paintingCmd
                               forPage:(WBPage *)page
                             withBlock:(WBSingleResultBlock)block;

- (void)addActionTextContentChangedElement:(TextElement *)element
                            withOriginText:(NSString *)text1
                           withChangedText:(NSString *)text2
                                   forPage:(WBPage *)page
                                 withBlock:(WBSingleResultBlock)block;

- (void)addActionTextFontChangedElement:(TextElement *)element
                     withOriginFontName:(NSString *)name1 fontSize:(int)size1
                    withChangedFontName:(NSString *)name2 fontSize:(int)size2
                                forPage:(WBPage *)page
                              withBlock:(WBSingleResultBlock)block;

- (void)addActionTextColorChangedElement:(TextElement *)element
                         withOriginColor:(UIColor *)color1 x:(float)x1 y:(float)y1
                        withChangedColor:(UIColor *)color2 x:(float)x2 y:(float)y2
                                 forPage:(WBPage *)page
                               withBlock:(WBSingleResultBlock)block;

- (void)clearHistoryPool;

@property (nonatomic, strong) NSMutableDictionary *historyPool;
@property (nonatomic, strong) HistoryAction *currentAction;
@property (nonatomic, assign) id<HistoryManagerDelegate> delegate;

@end
