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
- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden;

#pragma mark - Collaboration
@required
- (void)didCreateCanvasElementWithUid:(NSString *)elementUid
                              pageUid:(NSString *)pageUid;
- (void)didCreateTextElementWithUid:(NSString *)elementUid
                            pageUid:(NSString *)pageUid
                          textFrame:(CGRect)textFrame
                               text:(NSString *)text
                          textColor:(UIColor *)textColor
                           textFont:(NSString *)textFont
                           textSize:(float)textSize;
- (void)didApplyColorRed:(float)red
                   green:(float)green
                    blue:(float)blue
                   alpha:(float)alpha
              strokeSize:(float)strokeSize
              elementUid:(NSString *)elementUid
                 pageUid:(NSString *)pageUid;
- (void)didRenderLineFromPoint:(CGPoint)start
                       toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer
                     isErasing:(BOOL)isErasing
                    elementUid:(NSString *)elementUid
                       pageUid:(NSString *)pageUid;
- (void)didChangeTextContent:(NSString *)text
                  elementUid:(NSString *)elementUid
                     pageUid:(NSString *)pageUid;
- (void)didChangeTextFont:(NSString *)textFont
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid;
- (void)didChangeTextSize:(float)textSize
               elementUid:(NSString *)elementUid
                  pageUid:(NSString *)pageUid;
- (void)didChangeTextColor:(UIColor *)textColor
                elementUid:(NSString *)elementUid
                   pageUid:(NSString *)pageUid;
- (void)didMoveTo:(CGPoint)dest
       elementUid:(NSString *)elementUid
          pageUid:(NSString *)pageUid;
- (void)didRotateTo:(float)rotation
         elementUid:(NSString *)elementUid
            pageUid:(NSString *)pageUid;
- (void)didScaleTo:(float)scale
        elementUid:(NSString *)elementUid
           pageUid:(NSString *)pageUid;
- (void)didMoveTo:(CGPoint)dest
          pageUid:(NSString *)pageUid;
- (void)didScaleTo:(float)scale
           pageUid:(NSString *)pageUid;
- (void)didApplyFromTransform:(CGAffineTransform)from
                  toTransform:(CGAffineTransform)to
                transformName:(NSString *)transformName
                   elementUid:(NSString *)elementUid
                      pageUid:(NSString *)pageUid;
@end

@interface WBPage : UIView <WBBaseViewDelegate, UIGestureRecognizerDelegate>

- (UIImage *)exportPageToImage;
- (NSMutableDictionary *)saveToData;

- (void)addElement:(WBBaseElement *)element;
- (void)restoreElement:(WBBaseElement *)element;
- (void)removeElement:(WBBaseElement *)element;

- (void)addCanvas;
- (void)initBaseCanvasElement;
- (void)addText;
- (void)addBackgroundElementWithImage:(UIImage *)image;
- (void)startToMove;
- (void)stopToMove;

- (WBBaseElement *)elementByUid:(NSString *)elementUid;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) WBBaseElement *currentElement;
@property (nonatomic, assign) id<WBPageDelegate> pageDelegate;
@property (nonatomic) BOOL isMovable;

#pragma mark - Collaboration
- (void)createCanvasElementWithUid:(NSString *)elementUid;
- (void)createTextElementwithUid:(NSString *)elementUid
                       textFrame:(CGRect)textFrame
                            text:(NSString *)text
                       textColor:(UIColor *)textColor
                        textFont:(NSString *)textFont
                        textSize:(float)textSize;
- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize
           elementUid:(NSString *)elementUid;
- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing
                 elementUid:(NSString *)elementUid;
- (void)changeTextContent:(NSString *)text
               elementUid:(NSString *)elementUid;
- (void)changeTextFont:(NSString *)textFont
            elementUid:(NSString *)elementUid;
- (void)changeTextSize:(float)textSize
            elementUid:(NSString *)elementUid;
- (void)changeTextColor:(UIColor *)textColor
             elementUid:(NSString *)elementUid;
- (void)moveTo:(CGPoint)dest
    elementUid:(NSString *)elementUid;
- (void)rotateTo:(float)rotation
      elementUid:(NSString *)elementUid;
- (void)scaleTo:(float)scale
     elementUid:(NSString *)elementUid;
- (void)moveTo:(CGPoint)dest;
- (void)scaleTo:(float)scale;
- (void)applyFromTransform:(CGAffineTransform)from
               toTransform:(CGAffineTransform)to
             transformName:(NSString *)transformName
                elementUid:(NSString *)elementUid;

@end
