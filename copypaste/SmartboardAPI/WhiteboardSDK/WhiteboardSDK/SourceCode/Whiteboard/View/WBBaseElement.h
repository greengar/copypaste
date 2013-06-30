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
- (void)fakeCanvasFromElementShouldBeReal:(WBBaseElement *)element;
- (void)elementRevive:(WBBaseElement *)element;
- (void)element:(WBBaseElement *)element nowBringToFront:(BOOL)bringFront;
- (void)element:(WBBaseElement *)element nowSendToBack:(BOOL)sendBack;
- (void)element:(WBBaseElement *)element nowDeleted:(BOOL)deleted;
- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden;

#pragma mark - Collaboration Canvas
- (void)didCreateRealCanvasWithUid:(NSString *)elementUid;
- (void)didChangeTextContent:(NSString *)text
                  elementUid:(NSString *)elementUid;
- (void)didChangeTextFont:(NSString *)textFont
               elementUid:(NSString *)elementUid;
- (void)didChangeTextSize:(float)textSize
               elementUid:(NSString *)elementUid;
- (void)didChangeTextColor:(UIColor *)textColor
                elementUid:(NSString *)elementUid;
- (void)didApplyColorRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
              strokeSize:(float)strokeSize
              elementUid:(NSString *)elementUid;
- (void)didRenderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer isErasing:(BOOL)isErasing
                updateBoundary:(CGRect)boundingRect
                    elementUid:(NSString *)elementUid;
- (void)didMoveTo:(CGPoint)dest
       elementUid:(NSString *)elementUid;
- (void)didRotateTo:(float)rotation
         elementUid:(NSString *)elementUid;
- (void)didScaleTo:(float)scale
        elementUid:(NSString *)elementUid;
- (void)didApplyFromTransform:(CGAffineTransform)from
                  toTransform:(CGAffineTransform)to
                transformName:(NSString *)transformName
                   elementUid:(NSString *)elementUid;
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

- (void)applyFromTransform:(CGAffineTransform)from
               toTransform:(CGAffineTransform)to
             transformName:(NSString *)transformName;

#pragma mark - Backup/Restore
- (NSMutableDictionary *)saveToData;
- (void)loadFromData:(NSDictionary *)elementData;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, weak) id<WBBaseViewDelegate> delegate;
@property (nonatomic) CGRect defaultFrame;
@property (nonatomic) CGAffineTransform defaultTransform;
@property (nonatomic) CGAffineTransform currentTransform;
@property (nonatomic, strong) CAShapeLayer *border;

// For History Created
@property (nonatomic) BOOL elementCreated;
@property (nonatomic) BOOL isFake;

@end
