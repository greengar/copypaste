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
@synthesize elements = _elementViews;
@synthesize selectedElementView = _selectedElementView;
@synthesize pageDelegate = _pageDelegate;
@synthesize isLocked = _isLocked;

#pragma mark - Init Views
- (id)initWithDict:(NSDictionary *)dictionary {
    CGRect frame = CGRectFromString([dictionary objectForKey:@"page_frame"]);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.uid = [dictionary objectForKey:@"page_uid"];
        
        self.elements = [NSMutableArray new];
        
        NSMutableArray *elements = [dictionary objectForKey:@"page_elements"];
        for (NSDictionary *elementDict in elements) {
            WBBaseElement *element = [WBBaseElement loadFromDict:elementDict];
            [element setDelegate:self];
            [element deselect];
            [self addSubview:element];
            [self.elements addObject:element];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"P_"];
        self.elements = [NSMutableArray new];
        
        // Default has a Canvas Element
        GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addElement:canvasElement];
    }
    return self;
}

#pragma mark - Delegates back to super
- (void)select {
    [self.selectedElementView select];
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageSelected:)]) {
        [self.pageDelegate pageSelected:self];
    }
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
    for (WBBaseElement *element in self.elements) {
        [element setIsLocked:isLocked];
    }
}

#pragma mark - Elements Handler
- (void)addElement:(WBBaseElement *)element {
    [self addSubview:element];
    [self.elements addObject:element];
    [element setDelegate:self];
    [element select];

    [[HistoryManager sharedManager] addActionCreateElement:element
                                                   forPage:self
                                                 withBlock:^(HistoryElementCreated *history, NSError *error) {
         if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
             [self.pageDelegate pageHistoryCreated:history];
         }
    }];
}

- (void)restoreElement:(WBBaseElement *)element {
    [self addSubview:element];
    [self.elements addObject:element];
    [element setDelegate:self];
    [element restore];
}

- (void)removeElement:(WBBaseElement *)element {
    BOOL isExisted = NO;
    for (WBBaseElement *existedElement in self.elements) {
        if ([element.uid isEqualToString:existedElement.uid]) {
            isExisted = YES;
        }
    }
    
    if (isExisted) {
        [self.elements removeObject:element];
        if ([element superview]) {
            [element removeFromSuperview];
        }
    }
}

- (void)focusOnTopElement {
    if ([self.elements count]) {
        [self focusOnCanvas];
    } else {
        // There's always at least 1 element
        // And it should be the canvas view
        GLCanvasElement *element = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addElement:element];
    }
}

- (void)focusOnCanvas {
    if (self.selectedElementView
        && [self.selectedElementView isKindOfClass:[GLCanvasElement class]]
        && ![self.selectedElementView isTransformed]) {
        [self.selectedElementView select];
    } else {
        GLCanvasElement *canvasElement = [[GLCanvasElement alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addElement:canvasElement];
    }
}

- (void)focusOnText {
    if (self.selectedElementView
        && [self.selectedElementView isKindOfClass:[TextElement class]]) {
        [self.selectedElementView select];
    } else {
        TextElement *textElement = [[TextElement alloc] initWithFrame:CGRectMake(0, self.frame.size.height/8, self.frame.size.width, self.frame.size.height/2)];
        [self addElement:textElement];
    }
}

#pragma mark - Elements Delegate
- (void)deselectAll {
    for (WBBaseElement *existedElement in self.elements) {
        if (existedElement != self.selectedElementView) {
            [existedElement deselect];
        }
    }
}

- (void)elementUnlocked:(WBBaseElement *)element {
    [self setIsLocked:NO];
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageUnlocked:)]) {
        [self.pageDelegate pageUnlocked:self];
    }
}

- (void)elementSelected:(WBBaseElement *)element {
    self.selectedElementView = element;
    [self deselectAll];
    
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.pageDelegate elementSelected:element];
    }
}

- (void)elementDeselected:(WBBaseElement *)element {
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(elementDeselected:)]) {
        [self.pageDelegate elementDeselected:element];
    }
}

- (void)elementCreated:(WBBaseElement *)element successful:(BOOL)successful {
    if (successful) {
        [[HistoryManager sharedManager] addActionCreateElement:element forPage:self
                                                     withBlock:^(id object, NSError *error) {}];
    } else {
        [element removeFromSuperview];
        [self.elements removeObject:element];
    }
}

- (void)elementDeleted:(WBBaseElement *)element {
    [[HistoryManager sharedManager] addActionDeleteElement:element forPage:self
                                                 withBlock:^(HistoryAction *history, NSError *error) {
        if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
            [self.pageDelegate pageHistoryCreated:history];
        }
    }];
}

- (void)pageHistoryCreated:(HistoryAction *)history {
    if (self.pageDelegate && [((id) self.pageDelegate) respondsToSelector:@selector(pageHistoryCreated:)]) {
        [self.pageDelegate pageHistoryCreated:history];
    }
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"page_uid"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"page_frame"];
    
    NSMutableDictionary *elementPages = [NSMutableDictionary new];
    for (WBBaseElement *element in self.elements) {
        [elementPages setObject:[element saveToDict] forKey:element.uid];
    }
    [dict setObject:elementPages forKey:@"page_elements"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBPage *)loadFromDict:(NSDictionary *)dict {
    WBPage *page = [[WBPage alloc] initWithDict:dict];
    return page;
}

#pragma mark - Export
- (UIImage *)exportPageToImage {
    BOOL oldHidden = self.isHidden;
    [self setHidden:NO];
    for (WBBaseElement *element in self.elements) {
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
    for (WBBaseElement *element in self.elements) {
        if ([element isKindOfClass:[GLCanvasElement class]]) {
            GLCanvasElement *canvasElement = (GLCanvasElement *) element;
            [canvasElement removeScreenshot];
        }
    }
    [self setHidden:oldHidden];
    return exportedImage;
}

@end
