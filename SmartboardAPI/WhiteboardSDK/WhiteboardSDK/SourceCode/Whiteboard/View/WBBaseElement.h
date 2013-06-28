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
- (void)pageHistoryCreated:(HistoryAction *)history;
- (void)pageHistoryElementCanvasUpdated:(HistoryAction *)history withNewPaintingCmd:(PaintingCmd *)cmd;
- (void)fakeCanvasFromElementShouldBeReal:(WBBaseElement *)element;
- (void)elementRevive:(WBBaseElement *)element;
- (void)element:(WBBaseElement *)element nowBringToFront:(BOOL)bringFront;
- (void)element:(WBBaseElement *)element nowSendToBack:(BOOL)sendBack;
- (void)element:(WBBaseElement *)element nowDeleted:(BOOL)deleted;
- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden;
@end

@interface WBBaseElement : UIView <UIGestureRecognizerDelegate>

- (UIView *)contentView;

#pragma mark - Transform
- (void)moveTo:(CGPoint)dest;
- (void)rotateTo:(float)rotation;
- (void)scaleTo:(float)scale;
- (void)restore;
- (BOOL)isTransformed;
- (BOOL)isCropped;
- (void)resetTransform;
- (CGRect)focusFrame;

- (void)revive;
- (void)rest;
- (BOOL)isAlive;
- (void)move;
- (void)stay;
- (BOOL)isMovable;

- (void)crop;

#pragma mark - Backup/Restore
- (NSMutableDictionary *)saveToData;
- (void)loadFromData:(NSDictionary *)elementData;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) id<WBBaseViewDelegate> delegate;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) CGAffineTransform defaultTransform;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic, strong) CAShapeLayer *border;

// For History Created
@property (nonatomic) BOOL elementCreated;
@property (nonatomic) BOOL isFake;

@end
