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
@property (nonatomic, strong) GLCanvasElement *baseCanvasElement;
@property (nonatomic, strong) BackgroundElement *baseBackgroundElement;
@end

@implementation WBPage
@synthesize uid = _uid;
@synthesize currentElement = _currentElement;
@synthesize baseCanvasElement = _baseCanvasElement;
@synthesize baseBackgroundElement = _baseBackgroundElement;
@synthesize pageDelegate = _pageDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = YES;
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"P_"];
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
    if ([element isKindOfClass:[BackgroundElement class]]) {
        [self sendSubviewToBack:element];
    }
}

#pragma mark - Elements Delegate
- (void)element:(WBBaseElement *)element hideKeyboard:(BOOL)hidden {
    self.currentElement = element;
    [self.pageDelegate element:element hideKeyboard:hidden];
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

- (void)addCanvas {
    GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:canvasElement];
    self.currentElement = canvasElement;
    [self.currentElement setDelegate:self];
}

- (void)initBaseCanvasElement {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    self.baseCanvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addElement:self.baseCanvasElement];
}

- (void)addText {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    TextElement *textElement = [[TextElement alloc] initWithFrame:CGRectMake(0, self.frame.size.height/8,
                                                                             self.frame.size.width, self.frame.size.height/2)];
    [self addElement:textElement];
    [textElement revive];
    [self.pageDelegate didCreateTextElementWithUid:textElement.uid
                                           pageUid:self.uid
                                         textFrame:textElement.frame
                                              text:((UITextView *)textElement.contentView).text
                                         textColor:textElement.myColor
                                          textFont:textElement.myFontName
                                          textSize:textElement.myFontSize];
}

- (void)addBackgroundElementWithImage:(UIImage *)image {
    if ([[SettingManager sharedManager] viewOnly]) { return; }
    
    if ([self.baseBackgroundElement superview]) {
        [self.baseBackgroundElement removeFromSuperview];
    }
    
    self.baseBackgroundElement = [[BackgroundElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                                                    image:image];
    [self addElement:self.baseBackgroundElement];
    [self sendSubviewToBack:self.baseBackgroundElement];
}

- (void)startToMove {
    self.isMovable = YES;
    
    for (WBBaseElement *element in self.subviews) {
        [element move];
    }
}

- (void)stopToMove {
    self.isMovable = NO;
    
    for (WBBaseElement *element in self.subviews) {
        [element stay];
    }
    
    self.currentElement = self.baseCanvasElement;
}

- (void)startToPanZoom {
    UIPanGestureRecognizer *panGesture;
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pagePan:)];
    panGesture.maximumNumberOfTouches = 2;
    panGesture.delegate = self;

    [self addGestureRecognizer:panGesture];

    UIPinchGestureRecognizer *pinchGesture;
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pageScale:)];
    pinchGesture.delegate = self;

    [self addGestureRecognizer:pinchGesture];
}

- (void)stopToPanZoom {
    [[self layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [self setCenter:self.superview.center];
    
    [UIView beginAnimations:nil context:nil];
    [self setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
    
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
}

#pragma mark - Pan/Zoom Page
- (void)pagePan:(UIPanGestureRecognizer *)panGesture {
    [WBUtils adjustAnchorPointForGestureRecognizer:panGesture];
    if ([panGesture state] == UIGestureRecognizerStateBegan
        || [panGesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:[self superview]];
        [self moveTo:translation];
        [self.pageDelegate didMoveTo:translation
                             pageUid:self.uid];
        [panGesture setTranslation:CGPointZero inView:self];
    }
}

- (void)pageScale:(UIPinchGestureRecognizer *)pinchGesture {
    [WBUtils adjustAnchorPointForGestureRecognizer:pinchGesture];
    if ([pinchGesture state] == UIGestureRecognizerStateBegan
        || [pinchGesture state] == UIGestureRecognizerStateChanged) {
        float scale = pinchGesture.scale;
        [self scaleTo:scale];
        [self.pageDelegate didScaleTo:scale
                              pageUid:self.uid];
        [pinchGesture setScale:1.0f];
    }
}

#pragma mark - Transform
- (void)moveTo:(CGPoint)dest {
    self.center = CGPointMake(self.center.x+dest.x, self.center.y+dest.y);
}

- (void)scaleTo:(float)scale {
    [self setTransform:CGAffineTransformScale(self.transform, scale, scale)];
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
        [element takeScreenshot];
        
    }
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *exportedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    for (WBBaseElement *element in self.subviews) {
        [element removeScreenshot];
    }
    [self setHidden:oldHidden];
    return exportedImage;
}

- (void)dealloc {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        for (int i = [self.subviews count]-1; i >= 0; i--) {
            WBBaseElement *subview = [self.subviews objectAtIndex:i];
            if ([subview contentDrawingView]) {
                [subview touchesBegan:touches withEvent:event];
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        for (int i = [self.subviews count]-1; i >= 0; i--) {
            WBBaseElement *subview = [self.subviews objectAtIndex:i];
            if ([subview contentDrawingView]) {
                [subview touchesMoved:touches withEvent:event];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        for (int i = [self.subviews count]-1; i >= 0; i--) {
            WBBaseElement *subview = [self.subviews objectAtIndex:i];
            if ([subview contentDrawingView]) {
                [subview touchesEnded:touches withEvent:event];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isMovable) {
        for (int i = [self.subviews count]-1; i >= 0; i--) {
            WBBaseElement *subview = [self.subviews objectAtIndex:i];
            if ([subview contentDrawingView]) {
                [subview touchesCancelled:touches withEvent:event];
            }
        }
    }
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
                    elementUid:(NSString *)elementUid {
    [self.pageDelegate didRenderLineFromPoint:start
                                      toPoint:end
                               toURBackBuffer:toURBackBuffer
                                    isErasing:isErasing
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
                 elementUid:(NSString *)elementUid {
    WBBaseElement *element = [self elementByUid:elementUid];
    if ([element isKindOfClass:[GLCanvasElement class]]) {
        [((GLCanvasElement *) element) renderLineFromPoint:start
                                                   toPoint:end
                                            toURBackBuffer:toURBackBuffer
                                                 isErasing:isErasing];
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
