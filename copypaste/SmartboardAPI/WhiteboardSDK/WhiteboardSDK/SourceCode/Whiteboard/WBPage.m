//
//  WBPage.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBPage.h"
#import "GLCanvasElement.h"
#import "TextElement.h"
#import "ImageElement.h"
#import "BackgroundElement.h"
#import "WBUtils.h"
#import "GSButton.h"
#import "HistoryView.h"
#import "HistoryManager.h"
#import "HistoryElementCreated.h"
#import "HistoryElementDeleted.h"

#define kUndoPickerWidth 69
#define kURButtonWidthHeight 64

#define kCanvasButtonIndex  0
#define kTextButtonIndex    (kCanvasButtonIndex+1)
#define kHistoryButtonIndex (kCanvasButtonIndex+2)
#define kLockButtonIndex    (kCanvasButtonIndex+3)
#define kDoneButtonIndex    (kCanvasButtonIndex+4)

#define kTextFontButtonIndex 0
#define kTextColorButtonIndex (kTextFontButtonIndex+1)

#define kDefaultTextBoxWidth 200
#define kDefaultTextBoxHeight 60

#define kFontPickerHeight (IS_IPAD ? 264 : 344)
#define kFontColorPickerHeight (IS_IPAD ? 264 : 288)

@interface WBPage ()
@end

@implementation WBPage
@synthesize uid = _uid;
@synthesize currentElement = _currentElement;
@synthesize pageDelegate = _pageDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"P_"];
        
        [self addFakeCanvas];
    }
    return self;
}

#pragma mark - Elements Handler
- (void)addElement:(WBBaseElement *)element {
    [self addSubview:element];
    self.currentElement = element;
    [element setDelegate:self];

    [[HistoryManager sharedManager] addActionCreateElement:element
                                                   forPage:self
                                                 withBlock:^(HistoryElementCreated *history, NSError *error) {
    }];
}

- (void)removeElement:(WBBaseElement *)element {
    [element removeFromSuperview];
}

- (void)restoreElement:(WBBaseElement *)element {
    [self addSubview:element];
    [element setDelegate:self];
    [element restore];
}

#pragma mark - Elements Delegate
- (void)elementRevive:(WBBaseElement *)element {
    for (WBBaseElement *existedElement in self.subviews) {
        if (![existedElement.uid isEqualToString:element.uid]) {
            [existedElement stay];
            [existedElement rest];
        }
    }
    self.currentElement = element;
    
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(elementRevived)]) {
        [self.pageDelegate elementRevived];
    }
    
    if ([self.currentElement isKindOfClass:[TextElement class]]) {
        if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(textElementNowFocus)]) {
            [self.pageDelegate textElementNowFocus];
        }
    }
}

- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden {
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(elementHideKeyboard)]) {
        [self.pageDelegate elementHideKeyboard];
    }
}

- (void)element:(WBBaseElement *)element nowBringToFront:(BOOL)bringFront {
    if (bringFront) {
        self.currentElement = [self.subviews lastObject];
    }
}

- (void)element:(WBBaseElement *)element nowSendToBack:(BOOL)sendBack {
    if (sendBack) {
        self.currentElement = [self.subviews lastObject];
    }
}

- (void)element:(WBBaseElement *)element nowDeleted:(BOOL)deleted {
    if (deleted) {
        [self removeElement:element];
        self.currentElement = [self.subviews lastObject];
        [[HistoryManager sharedManager] addActionDeleteElement:element forPage:self
                                                     withBlock:^(HistoryElement *history, NSError *error) {}];

    }
}

#pragma mark - Fake/Real Canvas
- (void)fakeCanvasFromElementShouldBeReal:(WBBaseElement *)element {
    [self addElement:element];
}

- (void)addCanvas {
    GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:canvasElement];
    self.currentElement = canvasElement;
    [self.currentElement setDelegate:self];
    [self.currentElement revive];
    [self.currentElement stay];
}

- (void)addFakeCanvas {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    if ([self.currentElement isKindOfClass:[GLCanvasElement class]]
        && ![self.currentElement isTransformed]
        && ![self.currentElement isCropped]) {
        
    } else {
        GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:canvasElement];
        self.currentElement = canvasElement;
        [self.currentElement setDelegate:self];
    }
    
    [self.currentElement revive];
    [self.currentElement stay];
}

- (void)removeFakeCanvas {
    if ([self.currentElement isKindOfClass:[GLCanvasElement class]] && [self.currentElement isFake]) {
        [self.currentElement removeFromSuperview];
        self.currentElement = [self.subviews lastObject];
    }
}

- (void)addText {
    TextElement *textElement = [[TextElement alloc] initWithFrame:CGRectMake(0, self.frame.size.height/8,
                                                                             self.frame.size.width, self.frame.size.height/2)];
    [self addElement:textElement];
    
    [textElement setDelegate:self];
    [textElement revive];
    [textElement stay];
    
    [self.pageDelegate didCreateTextElementWithUid:textElement.uid
                                           pageUid:self.uid
                                         textFrame:textElement.frame
                                              text:((UITextView *)textElement.contentView).text
                                         textColor:textElement.myColor
                                          textFont:textElement.myFontName
                                          textSize:textElement.myFontSize];
}

- (void)startToMove {
    self.isMovable = YES;
    
    for (WBBaseElement *element in self.subviews) {
        [element crop];
        [element move];
        [element rest];
    }
}

- (void)stopToMove {
    self.isMovable = NO;
    
    for (WBBaseElement *element in self.subviews) {
        [element stay];
    }
}

#pragma mark - Backup/Restore Save/Load
- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"page_uid"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"page_frame"];
    return dict;
}

- (WBBaseElement *)elementByUid:(NSString *)elementUid {
    WBBaseElement *historyElement = nil;
    for (WBBaseElement *element in self.subviews) {
        if ([element.uid isEqualToString:elementUid]) {
            historyElement = element;
            break;
        }
    }
    return historyElement;
}

#pragma mark - Export
- (UIImage *)exportPageToImage {
    // TODO: cache image so we don't re-export an image if it hasn't changed since the last export?
    
    BOOL oldHidden = self.isHidden;
    [self setHidden:NO];
    for (WBBaseElement *element in self.subviews) {
        if ([element isKindOfClass:[GLCanvasElement class]]) {
            GLCanvasElement *canvasElement = (GLCanvasElement *) element;
            [canvasElement takeScreenshot];
        }
    }
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *exportedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    for (WBBaseElement *element in self.subviews) {
        if ([element isKindOfClass:[GLCanvasElement class]]) {
            GLCanvasElement *canvasElement = (GLCanvasElement *) element;
            [canvasElement removeScreenshot];
        }
    }
    [self setHidden:oldHidden];
    return exportedImage;
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Collaboration Back
- (void)didCreateRealCanvasWithUid:(NSString *)elementUid {
    [self.pageDelegate didCreateCanvasElementWithUid:elementUid
                                             pageUid:self.uid];
}

- (void)didApplyColorRed:(float)red
                   green:(float)green
                    blue:(float)blue
                   alpha:(float)alpha
              strokeSize:(float)strokeSize
              elementUid:(NSString *)elementUid {
    [self.pageDelegate didApplyColorRed:red
                                  green:green
                                   blue:blue
                                  alpha:alpha
                             strokeSize:strokeSize
                             elementUid:elementUid
                                pageUid:self.uid];
}

- (void)didRenderLineFromPoint:(CGPoint)start
                       toPoint:(CGPoint)end
                toURBackBuffer:(BOOL)toURBackBuffer
                     isErasing:(BOOL)isErasing
                updateBoundary:(CGRect)boundingRect
                    elementUid:(NSString *)elementUid {
    [self.pageDelegate didRenderLineFromPoint:start
                                      toPoint:end
                               toURBackBuffer:toURBackBuffer
                                    isErasing:isErasing
                               updateBoundary:boundingRect
                                   elementUid:elementUid
                                      pageUid:self.uid];
}

- (void)didChangeTextContent:(NSString *)text
                  elementUid:(NSString *)elementUid {
    [self.pageDelegate didChangeTextContent:text
                                 elementUid:elementUid
                                    pageUid:self.uid];
}

- (void)didChangeTextFont:(NSString *)textFont
               elementUid:(NSString *)elementUid {
    [self.pageDelegate didChangeTextFont:textFont
                              elementUid:elementUid
                                 pageUid:self.uid];
}

- (void)didChangeTextSize:(float)textSize
               elementUid:(NSString *)elementUid {
    [self.pageDelegate didChangeTextSize:textSize
                              elementUid:elementUid
                                 pageUid:self.uid];
}

- (void)didChangeTextColor:(UIColor *)textColor
                elementUid:(NSString *)elementUid {
    [self.pageDelegate didChangeTextColor:textColor
                               elementUid:elementUid
                                  pageUid:self.uid];
}

- (void)didMoveTo:(CGPoint)dest elementUid:(NSString *)elementUid {
    [self.pageDelegate didMoveTo:dest elementUid:elementUid pageUid:self.uid];
}

- (void)didRotateTo:(float)rotation elementUid:(NSString *)elementUid {
    [self.pageDelegate didRotateTo:rotation elementUid:elementUid pageUid:self.uid];
}

- (void)didScaleTo:(float)scale elementUid:(NSString *)elementUid {
    [self.pageDelegate didScaleTo:scale elementUid:elementUid pageUid:self.uid];
}

- (void)didApplyFromTransform:(CGAffineTransform)from toTransform:(CGAffineTransform)to
                transformName:(NSString *)transformName elementUid:(NSString *)elementUid {
    [self.pageDelegate didApplyFromTransform:from
                                 toTransform:to
                               transformName:transformName
                                  elementUid:elementUid
                                     pageUid:self.uid];
}

#pragma mark - Collaboration Forward
- (void)createCanvasElementWithUid:(NSString *)elementUid {
    GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [canvasElement setUid:elementUid];
    [canvasElement setDelegate:self];
    [self addSubview:canvasElement];
    [canvasElement createRealCanvas];
    [canvasElement rest];
    [canvasElement stay];
}

- (void)createTextElementwithUid:(NSString *)elementUid
                       textFrame:(CGRect)textFrame
                            text:(NSString *)text
                       textColor:(UIColor *)textColor
                        textFont:(NSString *)textFont
                        textSize:(float)textSize {
    TextElement *textElement = [[TextElement alloc] initWithFrame:textFrame];
    [textElement setUid:elementUid];
    [textElement setDelegate:self];
    [textElement setMyFontName:textFont];
    [textElement setMyColor:textColor];
    [textElement setMyFontSize:textSize];
    [self addSubview:textElement];
    [textElement rest];
    [textElement stay];
}

- (void)applyColorRed:(float)red
                green:(float)green
                 blue:(float)blue
                alpha:(float)alpha
           strokeSize:(float)strokeSize
           elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[GLCanvasElement class]]) {
        [((GLCanvasElement *) element) applyColorRed:red
                                               green:green
                                                blue:blue
                                               alpha:alpha
                                          strokeSize:strokeSize];
    }
}

- (void)renderLineFromPoint:(CGPoint)start
                    toPoint:(CGPoint)end
             toURBackBuffer:(BOOL)toURBackBuffer
                  isErasing:(BOOL)isErasing
             updateBoundary:(CGRect)rect
                 elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[GLCanvasElement class]]) {
        [((GLCanvasElement *) element) renderLineFromPoint:start
                                                   toPoint:end
                                            toURBackBuffer:toURBackBuffer
                                                 isErasing:isErasing
                                            updateBoundary:rect];
    }
}

- (void)changeTextContent:(NSString *)text
               elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[TextElement class]]) {
        [((TextElement *) element) setText:text];
    }
}

- (void)changeTextFont:(NSString *)textFont
            elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[TextElement class]]) {
        [((TextElement *) element) updateWithFontName:textFont];
    }
}

- (void)changeTextSize:(float)textSize
            elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[TextElement class]]) {
        [((TextElement *) element) updateWithFontSize:textSize];
    }
}

- (void)changeTextColor:(UIColor *)textColor
             elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[TextElement class]]) {
        [((TextElement *) element) updateWithColor:textColor];
    }
}

- (void)moveTo:(CGPoint)dest
    elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if (element) {
        [element moveTo:dest];
    }
}

- (void)rotateTo:(float)rotation
      elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if (element) {
        [element rotateTo:rotation];
    }
}

- (void)scaleTo:(float)scale
     elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if (element) {
        [element scaleTo:scale];
    }
}

- (void)applyFromTransform:(CGAffineTransform)from toTransform:(CGAffineTransform)to
             transformName:(NSString *)transformName
                elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if (element) {
        [element applyFromTransform:from toTransform:to transformName:transformName];
    }
}

@end
