//
//  SDPage.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBPage.h"
#import "CanvasElement.h"
#import "TextElement.h"
#import "ImageElement.h"
#import "BackgroundElement.h"
#import "WBUtils.h"
#import "GSButton.h"

#define kToolBarItemWidth   (frame.size.width/5)
#define kToolBarItemHeight  44

#define kCanvasButtonIndex  0
#define kTextButtonIndex    (kCanvasButtonIndex+1)
#define kHistoryButtonIndex (kCanvasButtonIndex+2)
#define kLockButtonIndex    (kCanvasButtonIndex+3)
#define kDoneButtonIndex    (kCanvasButtonIndex+4)

#define kTextFontButtonIndex 0
#define kTextColorButtonIndex (kTextFontButtonIndex+1)

#define kDefaultTextBoxWidth 200
#define kDefaultTextBoxHeight 60

#define kFontPickerHeight 344
#define kFontColorPickerHeight 288

@interface WBPage()
@property (nonatomic, strong) UIView         *toolBarView;
@property (nonatomic, strong) NSMutableArray *toolBarButtons;
@property (nonatomic, strong) NSMutableArray *textToolBarButtons;
@property (nonatomic, strong) FontPickerView *fontPickerView;
@property (nonatomic, strong) FontColorPickerView *fontColorPickerView;
@property (nonatomic, strong) BackgroundElement *backgroundImageView;
@end

@implementation WBPage
@synthesize uid = _uid;
@synthesize toolBarButtons = _toolBarButtons;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize elements = _elementViews;
@synthesize selectedElementView = _selectedElementView;
@synthesize fontPickerView = _fontPickerView;
@synthesize fontColorPickerView = _fontColorPickerView;
@synthesize delegate = _delegate;

- (id)initWithDict:(NSDictionary *)dictionary {
    CGRect frame = CGRectFromString([dictionary objectForKey:@"page_frame"]);
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [dictionary objectForKey:@"page_uid"];
        
        self.toolBarButtons = [NSMutableArray arrayWithCapacity:5];
        self.textToolBarButtons = [NSMutableArray arrayWithCapacity:2];
        self.elements = [NSMutableArray new];
        
        NSMutableArray *elements = [dictionary objectForKey:@"page_elements"];
        for (NSDictionary *elementDict in elements) {
            WBBaseElement *element = [WBBaseElement loadFromDict:elementDict];
            [element setDelegate:self];
            [element deselect];
            [self addSubview:element];
            [self.elements addObject:element];
        }
        
        [self initControlWithFrame:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"P_"];
        
        self.toolBarButtons = [NSMutableArray arrayWithCapacity:5];
        self.textToolBarButtons = [NSMutableArray arrayWithCapacity:2];
        self.elements = [NSMutableArray new];
        
        [self initControlWithFrame:frame];
    }
    return self;
}

#pragma mark - Tool Bar Buttons
- (void)initControlWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor clearColor];
    
    [self initToolBarViewWithFrame:frame];
    
    // Default: show tool bar
    [self showToolBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)initToolBarViewWithFrame:(CGRect)frame {
    self.toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                frame.size.height-kToolBarItemHeight,
                                                                frame.size.width,
                                                                kToolBarItemHeight)];
    [self addSubview:self.toolBarView];
    
    [self initToolBarButtonsWithFrame:frame];
    [self initTextToolBarButtonsWithFrame:frame];
}

- (void)initToolBarButtonsWithFrame:(CGRect)frame {
    GSButton *canvasButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:BlueButtonStyle];
    [canvasButton setTitle:@"Canvas" forState:UIControlStateNormal];
    [canvasButton setFrame:CGRectMake(kToolBarItemWidth*0, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [canvasButton addTarget:self action:@selector(newCanvas) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:canvasButton];
    [self.toolBarButtons addObject:canvasButton];
    
    GSButton *textButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:TanButtonStyle];
    [textButton setTitle:@"Text" forState:UIControlStateNormal];
    [textButton setFrame:CGRectMake(kToolBarItemWidth, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [textButton addTarget:self action:@selector(newText) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:textButton];
    [self.toolBarButtons addObject:textButton];
    
    GSButton *historyButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:OrangeButtonStyle];
    [historyButton setTitle:@"History" forState:UIControlStateNormal];
    [historyButton setFrame:CGRectMake(kToolBarItemWidth*2, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [historyButton addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:historyButton];
    [self.toolBarButtons addObject:historyButton];
    
    GSButton *lockButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:WhiteButtonStyle];
    [lockButton setTitle:@"Lock" forState:UIControlStateNormal];
    [lockButton setFrame:CGRectMake(kToolBarItemWidth*3, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [lockButton addTarget:self action:@selector(lockPage) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:lockButton];
    [self.toolBarButtons addObject:lockButton];
    
    GSButton *doneButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(kToolBarItemWidth*4, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [doneButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:doneButton];
    [self.toolBarButtons addObject:doneButton];
}

- (void)initTextToolBarButtonsWithFrame:(CGRect)frame {
    GSButton *fontButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:OrangeButtonStyle];
    [fontButton setTitle:@"Font" forState:UIControlStateNormal];
    [fontButton setFrame:CGRectMake(kToolBarItemWidth*0, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [fontButton addTarget:self action:@selector(selectFont) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:fontButton];
    [self.textToolBarButtons addObject:fontButton];
    
    GSButton *colorButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
    [colorButton setTitle:@"Color" forState:UIControlStateNormal];
    [colorButton setFrame:CGRectMake(kToolBarItemWidth*2, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [colorButton addTarget:self action:@selector(selectColor) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:colorButton];
    [self.textToolBarButtons addObject:colorButton];
    
    [self.textToolBarButtons addObject:[self.toolBarButtons objectAtIndex:kTextButtonIndex]];
    
    self.fontPickerView = [[FontPickerView alloc] initWithFrame:CGRectMake(0,
                                                                           frame.size.height-kFontPickerHeight,
                                                                           frame.size.width,
                                                                           kFontPickerHeight)];
    
    [self.fontPickerView setHidden:YES];
    [self addSubview:self.fontPickerView];
    
    self.fontColorPickerView = [[FontColorPickerView alloc] initWithFrame:CGRectMake(0,
                                                                                     frame.size.height-kFontColorPickerHeight,
                                                                                     frame.size.width, kFontColorPickerHeight)];
    [self.fontColorPickerView setHidden:YES];
    [self addSubview:self.fontColorPickerView];
}

- (void)showToolBar {
    for (GSButton *button in self.textToolBarButtons) {
        [button setHidden:YES];
    }
    for (GSButton *button in self.toolBarButtons) {
        [button setHidden:NO];
    }
    [self bringSubviewToFront:self.toolBarView];
}

- (void)showTextToolBar {
    for (GSButton *button in self.toolBarButtons) {
        [button setHidden:YES];
    }
    for (GSButton *button in self.textToolBarButtons) {
        [button setHidden:NO];
    }
    [self bringSubviewToFront:self.toolBarView];
}

#pragma mark - Delegates back to super
- (void)select {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageSelected:)]) {
        [self.delegate pageSelected:self];
    }
}

#pragma mark - Background image
- (void)setBackgroundImage:(UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:@"Whiteboard.bundle/DefaultBackground.png"];
    }
    
    self.backgroundImageView = [[BackgroundElement alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                self.frame.size.width,
                                                                                self.frame.size.height)
                                                               image:image];
    [self.backgroundImageView setDelegate:self];
    [self addSubview:self.backgroundImageView];
    [self.elements insertObject:self.backgroundImageView atIndex:0];
    
    [self sendSubviewToBack:self.backgroundImageView];
}

#pragma mark - Tool Bar Buttons
- (void)newCanvas {
    CanvasElement *canvasView = [[CanvasElement alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          self.frame.size.width,
                                                                          self.frame.size.height)
                                                         image:nil];
    [canvasView setDelegate:self];
    [self addSubview:canvasView];
    [self.elements addObject:canvasView];
    
    [self elementSelected:canvasView];
}

- (void)newText {
    TextElement *textView = [[TextElement alloc] initWithFrame:CGRectMake((self.frame.size.width-kDefaultTextBoxWidth)/2,
                                                                    self.frame.size.height/4,
                                                                    kDefaultTextBoxWidth,
                                                                    kDefaultTextBoxHeight)];
    [textView setDelegate:self];
    [self addSubview:textView];
    [self.elements addObject:textView];
    
    [self elementSelected:textView];
}

- (void)showHistory {
    
}

- (void)lockPage {
    
}

- (void)doneEditing {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneEditingPage:)]) {
        [self.delegate doneEditingPage:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)selectFont {
    if ([self.selectedElementView isKindOfClass:[TextElement class]]) {
        [((UITextView *)[self.selectedElementView contentView]) resignFirstResponder];
        [self.fontPickerView setCurrentTextView:((TextElement *)self.selectedElementView)];
        [self.fontPickerView setHidden:NO];
        [self bringSubviewToFront:self.fontPickerView];
    }
}

- (void)selectColor {
    if ([self.selectedElementView isKindOfClass:[TextElement class]]) {
        [((UITextView *)[self.selectedElementView contentView]) resignFirstResponder];
        [self.fontColorPickerView setCurrentTextView:((TextElement *)self.selectedElementView)];
        [self.fontColorPickerView setHidden:NO];
        [self bringSubviewToFront:self.fontColorPickerView];
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

- (void)elementSelected:(WBBaseElement *)element {
    self.selectedElementView = element;
    [self deselectAll];
    [element select];
    
    if ([element isKindOfClass:[TextElement class]]) {
        [self showTextToolBar];
    } else if (![element isKindOfClass:[CanvasElement class]]) {
        [self showToolBar];
    }
}

- (void)elementDeselected:(WBBaseElement *)element {
    if ([element isKindOfClass:[TextElement class]]) {
        [self.fontPickerView setHidden:YES];
        [self.fontColorPickerView setHidden:YES];
    } else if ([element isKindOfClass:[CanvasElement class]]) {
        [self showToolBar];
    }
}

#pragma mark - UI for Text View
- (void)showControlForTextView {
    
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if ([self.selectedElementView isKindOfClass:[TextElement class]]) {
        // Show Text Control
        [self showTextToolBar];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.toolBarView.frame;
        frame.origin.y -= kbSize.height;
        self.toolBarView.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (![self.selectedElementView isKindOfClass:[TextElement class]]) {
        // Show Text Control
        [self showToolBar];
    }
    
    [UIView animateWithDuration:0.2f animations:^{        
        CGRect frame = self.toolBarView.frame;
        frame.origin.y += kbSize.height;
        self.toolBarView.frame = frame;
    }];
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"page_uid"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"page_frame"];
    
    NSMutableArray *elementArray = [NSMutableArray new];
    for (WBBaseElement *element in self.elements) {
        NSDictionary *elementDict = [element saveToDict];
        [elementArray addObject:elementDict];
    }
    
    [dict setObject:elementArray forKey:@"page_elements"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (WBPage *)loadFromDict:(NSDictionary *)dict {
    WBPage *page = [[WBPage alloc] initWithDict:dict];
    return page;
}

#pragma mark - Export
- (UIImage *)exportPageToImage {
    [self.toolBarView setHidden:YES];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *exportedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.toolBarView setHidden:NO];
    return exportedImage;
}

@end
