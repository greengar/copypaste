//
//  SDBaseElement.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class WBPage;
@class WBBaseElement;
@class HistoryAction;
@class PaintingCmd;

@protocol WBBaseViewDelegate
@optional
- (void)elementCreated:(WBBaseElement *)element successful:(BOOL)successful;
- (void)elementSelected:(WBBaseElement *)element;
- (void)elementDeselected:(WBBaseElement *)element;
- (void)elementDeleted:(WBBaseElement *)element;
- (void)elementUnlocked:(WBBaseElement *)element;
- (void)pageHistoryCreated:(HistoryAction *)history;
- (void)pageHistoryElementCanvasUpdated:(HistoryAction *)history withNewPaintingCmd:(PaintingCmd *)cmd;
- (void)fakeCanvasFromElementShouldBeReal:(WBBaseElement *)element;
@end

@interface WBBaseElement : UIView <UIGestureRecognizerDelegate>

- (UIView *)contentView;

- (void)moveTo:(CGPoint)dest;
- (void)rotateTo:(float)rotation;
- (void)scaleTo:(float)scale;

- (void)select;
- (void)deselect;
- (void)restore;

- (BOOL)isTransformed;

- (void)resetTransform;
- (CGRect)focusFrame;

- (NSMutableDictionary *)saveToData;
- (void)loadFromData:(NSDictionary *)elementData;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL isLocked;
@property (nonatomic, assign) id<WBBaseViewDelegate> delegate;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) CGAffineTransform defaultTransform;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic, strong) CAShapeLayer *border;

// For History Created
@property (nonatomic) BOOL elementCreated;

@end
