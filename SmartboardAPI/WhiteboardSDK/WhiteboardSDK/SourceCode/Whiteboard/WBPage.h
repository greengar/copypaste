//
//  WBPage.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBUtils.h"
#import "WBBaseElement.h"
#import "GLCanvasElement.h"
#import "CGCanvasElement.h"
#import "HistoryAction.h"

@class WBPage;
@class WBBaseElement;
@class HistoryAction;
@class PaintingCmd;
@protocol WBPageDelegate
@optional
- (void)pageHistoryCreated:(HistoryAction *)history;
- (void)pageHistoryElementCanvasDrawUpdated:(HistoryAction *)history withPaintingCmd:(PaintingCmd *)cmd;
- (void)pageHistoryElementTransformUpdated:(HistoryAction *)history;
- (void)elementHideKeyboard;
- (void)elementRevived;
- (void)textElementNowFocus;
@end

@interface WBPage : UIView <UIScrollViewDelegate, UIAlertViewDelegate, WBBaseViewDelegate>

- (UIImage *)exportPageToImage;
- (NSMutableDictionary *)saveToData;

- (void)addElement:(WBBaseElement *)element;
- (void)restoreElement:(WBBaseElement *)element;
- (void)removeElement:(WBBaseElement *)element;

- (void)addFakeCanvas;
- (void)removeFakeCanvas;
- (void)addText;
- (void)startToMove;
- (void)stopToMove;

- (WBBaseElement *)elementByUid:(NSString *)elementUid;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) WBBaseElement *currentElement;
@property (nonatomic, assign) id<WBPageDelegate> pageDelegate;
@property (nonatomic) BOOL isMovable;

@end
