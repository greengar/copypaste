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
         if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
             [self.pageDelegate pageHistoryCreated:history];
         }
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
            [existedElement rest];
            [existedElement stay];
        }
    }
    self.currentElement = element;
    
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(elementRevived)]) {
        [self.pageDelegate elementRevived];
    }
    
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(textElementNowFocus)]) {
        [self.pageDelegate textElementNowFocus];
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
                                                     withBlock:^(HistoryAction *history, NSError *error) {
                                                         if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
                                                             [self.pageDelegate pageHistoryCreated:history];
                                                         }
                                                     }];

    }
}

- (void)pageHistoryCreated:(HistoryAction *)history {
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
        [self.pageDelegate pageHistoryCreated:history];
    }
}

- (void)pageHistoryElementCanvasUpdated:(HistoryAction *)history withNewPaintingCmd:(PaintingCmd *)cmd {
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryElementCanvasDrawUpdated:withPaintingCmd:)]) {
        [self.pageDelegate pageHistoryElementCanvasDrawUpdated:history withPaintingCmd:cmd];
    }
}

#pragma mark - Fake/Real Canvas
- (void)fakeCanvasFromElementShouldBeReal:(WBBaseElement *)element {
    [self addElement:element];
}

- (void)addFakeCanvas {
    GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:canvasElement];
    self.currentElement = canvasElement;
    
    [canvasElement setDelegate:self];
    [canvasElement revive];
    [canvasElement stay];
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
}

- (void)startToMove {
    self.isMovable = YES;
    
    for (WBBaseElement *element in self.subviews) {
        [element move];
        [element rest];
    }
}

- (void)stopToMove {
    self.isMovable = NO;
    
    for (WBBaseElement *element in self.subviews) {
        [element stay];
        [element rest];
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


@end
