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
#import "HistoryView.h"
#import "HistoryManager.h"
#import "FDCurlViewControl.h"

#define kElementZIndex              0
#define kToolBarZIndex              1
#define kTextToolBarZIndex          2
#define kPageCurlZIndex             3
#define kPageUnCurlZIndex           4
#define kCanvasPickerZIndex         5
#define kCanvasTabZIndex            6
#define kCanvasUndoZIndex           7
#define kCanvasRedoZIndex           8
#define kTextFontPickerZIndex       9
#define kTextColorPickerZIndex      10
#define kHistoryBarZIndex           11

#define kToolBarItemWidth   (IS_IPAD ? 110 : 64)
#define kToolBarItemHeight  (IS_IPAD ? 110 : 64)
#define kPageCurlWidth      (IS_IPAD ? 89 : 64)
#define kPageCurlHeight     (IS_IPAD ? 137 : 99)

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

#define kFontPickerHeight 344
#define kFontColorPickerHeight 288

@interface WBPage()
@property (nonatomic, strong) UIView         *elementLayer;
@property (nonatomic, strong) UIView         *toolLayer;
@property (nonatomic, strong) UIView         *textToolLayer;
@property (nonatomic, strong) NSMutableArray *toolBarButtons;
@property (nonatomic, strong) NSMutableArray *textToolBarButtons;
@property (nonatomic, strong) FontPickerView *fontPickerView;
@property (nonatomic, strong) FontColorPickerView *fontColorPickerView;
@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, strong) UIButton *redoButton;
@property (nonatomic, strong) ColorTabView *colorTabView;
@property (nonatomic, strong) ColorPickerView *colorPickerView;
@property (nonatomic, strong) BackgroundElement *backgroundImageView;
@property (nonatomic, strong) HistoryView    *historyView;
@property (nonatomic, strong) GSButton *pageCurlButton;
@end

@implementation WBPage
@synthesize uid = _uid;
@synthesize elementLayer = _elementLayer;
@synthesize toolLayer = _toolLayer;
@synthesize toolBarButtons = _toolBarButtons;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize elements = _elementViews;
@synthesize selectedElementView = _selectedElementView;
@synthesize fontPickerView = _fontPickerView;
@synthesize fontColorPickerView = _fontColorPickerView;
@synthesize delegate = _delegate;
@synthesize colorTabView = _colorTabView;
@synthesize colorPickerView = _colorPickerView;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize historyView = _historyView;
@synthesize pageCurlButton = _pageCurlButton;

#pragma mark - Init Views
- (id)initWithDict:(NSDictionary *)dictionary {
    CGRect frame = CGRectFromString([dictionary objectForKey:@"page_frame"]);
    self = [super initWithFrame:frame];
    if (self) {
        self.uid = [dictionary objectForKey:@"page_uid"];
        
        self.toolBarButtons = [NSMutableArray arrayWithCapacity:5];
        self.textToolBarButtons = [NSMutableArray arrayWithCapacity:2];
        self.elements = [NSMutableArray new];
        
        [self initLayersWithFrame:frame];
        
        NSMutableArray *elements = [dictionary objectForKey:@"page_elements"];
        for (NSDictionary *elementDict in elements) {
            WBBaseElement *element = [WBBaseElement loadFromDict:elementDict];
            [element setDelegate:self];
            [element deselect];
            [self insertSubview:element atIndex:kElementZIndex];
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
        
        [self initLayersWithFrame:frame];
        
        [self initControlWithFrame:frame];
    }
    return self;
}

- (void)initLayersWithFrame:(CGRect)frame {    
    // Elements
    self.elementLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.elementLayer setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:self.elementLayer atIndex:kElementZIndex];
    
    // Canvas/Text/History/Lock
    self.toolLayer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              frame.size.height-kToolBarItemHeight,
                                                              kToolBarItemWidth*3,
                                                              kToolBarItemHeight)];
    [self.toolLayer setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:self.toolLayer atIndex:kToolBarZIndex];
    [self initToolBarButtonsWithFrame:frame];
    
    // Font/Text/Color
    self.textToolLayer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  frame.size.height-kToolBarItemHeight,
                                                                  kToolBarItemWidth*3,
                                                                  kToolBarItemHeight)];
    [self.textToolLayer setBackgroundColor:[UIColor clearColor]];
    [self insertSubview:self.textToolLayer atIndex:kTextToolBarZIndex];
    [self initTextToolBarButtonsWithFrame:frame];
    
    // Canvas
    [self initCanvasControlWithFrame:frame];
}

- (void)initControlWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor clearColor];
    
    // Default: show tool bar
    [self showToolBar];
    
    // Init History view
    [self initHistoryViewWithFrame:frame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)initHistoryViewWithFrame:(CGRect)frame {
    self.historyView = [[HistoryView alloc] initWithFrame:CGRectMake(0,
                                                                     frame.size.height-kToolBarItemHeight*4,
                                                                     frame.size.width,
                                                                     kToolBarItemHeight*4)];
    [self.historyView setHidden:YES];
    [self insertSubview:self.historyView atIndex:kHistoryBarZIndex];
}

- (void)initToolBarButtonsWithFrame:(CGRect)frame {
    GSButton *canvasButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [canvasButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/PencilButton.fw.png"]
                            forState:UIControlStateNormal];
    [canvasButton setFrame:CGRectMake(kToolBarItemWidth*0, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [canvasButton addTarget:self action:@selector(newCanvas:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolLayer addSubview:canvasButton];
    [self.toolBarButtons addObject:canvasButton];
    
    GSButton *textButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [textButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/TextButton.fw.png"]
                          forState:UIControlStateNormal];
    [textButton setFrame:CGRectMake(kToolBarItemWidth, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [textButton addTarget:self action:@selector(newText:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolLayer addSubview:textButton];
    [self.toolBarButtons addObject:textButton];
    
    GSButton *historyButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/HistoryButton.fw.png"]
                             forState:UIControlStateNormal];
    [historyButton setFrame:CGRectMake(kToolBarItemWidth*2, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [historyButton addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.toolLayer addSubview:historyButton];
    [self.toolBarButtons addObject:historyButton];
    
//    GSButton *lockButton = [GSButton buttonWithType:UIButtonTypeCustom];
//    [lockButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/MoveButton.fw.png"]
//                          forState:UIControlStateNormal];
//    [lockButton setFrame:CGRectMake(kToolBarItemWidth*3, 0, kToolBarItemWidth, kToolBarItemHeight)];
//    [lockButton addTarget:self action:@selector(lockPage) forControlEvents:UIControlEventTouchUpInside];
//    [self.toolLayer addSubview:lockButton];
//    [self.toolBarButtons addObject:lockButton];
    
    self.pageCurlButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [self.pageCurlButton setImage:[UIImage imageNamed:@"Whiteboard.bundle/PageCurl.png"]
                    forState:UIControlStateNormal];
    [self.pageCurlButton setFrame:CGRectMake(frame.size.width-kPageCurlWidth,
                                             frame.size.height-kPageCurlHeight,
                                             kPageCurlWidth,
                                             kPageCurlHeight)];
    [self.pageCurlButton addTarget:self action:@selector(doneEditing)
             forControlEvents:UIControlEventTouchUpInside];
    [self insertSubview:self.pageCurlButton atIndex:kPageCurlZIndex];
}

- (void)initTextToolBarButtonsWithFrame:(CGRect)frame {
    GSButton *fontButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:OrangeButtonStyle];
    [fontButton setTitle:@"Font" forState:UIControlStateNormal];
    [fontButton setFrame:CGRectMake(kToolBarItemWidth*0, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [fontButton addTarget:self action:@selector(selectFont) forControlEvents:UIControlEventTouchUpInside];
    [self.textToolLayer addSubview:fontButton];
    [self.textToolBarButtons addObject:fontButton];
    
    GSButton *textButton = [GSButton buttonWithType:UIButtonTypeCustom];
    [textButton setBackgroundImage:[UIImage imageNamed:@"Whiteboard.bundle/TextButton.fw.png"]
                          forState:UIControlStateNormal];
    [textButton setFrame:CGRectMake(kToolBarItemWidth, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [textButton addTarget:self action:@selector(newText:) forControlEvents:UIControlEventTouchUpInside];
    [self.textToolLayer addSubview:textButton];
    [self.textToolBarButtons addObject:textButton];
    
    GSButton *colorButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
    [colorButton setTitle:@"Color" forState:UIControlStateNormal];
    [colorButton setFrame:CGRectMake(kToolBarItemWidth*2, 0, kToolBarItemWidth, kToolBarItemHeight)];
    [colorButton addTarget:self action:@selector(selectColor) forControlEvents:UIControlEventTouchUpInside];
    [self.textToolLayer addSubview:colorButton];
    [self.textToolBarButtons addObject:colorButton];
    
    [self.textToolBarButtons addObject:[self.toolBarButtons objectAtIndex:kTextButtonIndex]];
    
    self.fontPickerView = [[FontPickerView alloc] initWithFrame:CGRectMake(0,
                                                                           frame.size.height-kFontPickerHeight,
                                                                           frame.size.width,
                                                                           kFontPickerHeight)];
    
    [self.fontPickerView setHidden:YES];
    [self insertSubview:self.fontPickerView atIndex:kTextFontPickerZIndex];
    
    self.fontColorPickerView = [[FontColorPickerView alloc] initWithFrame:CGRectMake(0,
                                                                                     frame.size.height-kFontColorPickerHeight,
                                                                                     frame.size.width, kFontColorPickerHeight)];
    [self.fontColorPickerView setHidden:YES];
    [self insertSubview:self.fontColorPickerView atIndex:kTextColorPickerZIndex];
}

- (void)initCanvasControlWithFrame:(CGRect)frame {
    [self initColorPickerWithFrame:frame];
    [self initUndoRedoButtonsWithFrame:frame];
}

#pragma mark - Show Hide Views
- (void)showToolBar {
    [self.toolLayer setHidden:NO];
    [self.textToolLayer setHidden:YES];
    [((GSButton *)[self.toolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:NO];
    [((GSButton *)[self.textToolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:NO];
}

- (void)showTextToolBar {
    [self.toolLayer setHidden:YES];
    [self.textToolLayer setHidden:NO];
    [((GSButton *)[self.toolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:YES];
    [((GSButton *)[self.textToolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:YES];
}

- (void)showHistoryView {
    [self.historyView setHidden:NO];
}

- (void)hideHistoryView {
    [self.historyView setHidden:YES];
}

- (void)showFontPickerView {
    if ([self.selectedElementView isKindOfClass:[TextElement class]]) {
        [((UITextView *)[self.selectedElementView contentView]) resignFirstResponder];
        [self.fontPickerView setCurrentTextView:((TextElement *)self.selectedElementView)];
        [self.fontPickerView setHidden:NO];
    }
}

- (void)hideFontPickerView {
    [self.fontPickerView setHidden:YES];
}

- (void)showFontColorPickerView {
    if ([self.selectedElementView isKindOfClass:[TextElement class]]) {
        [((UITextView *)[self.selectedElementView contentView]) resignFirstResponder];
        [self.fontColorPickerView setCurrentTextView:((TextElement *)self.selectedElementView)];
        [self.fontColorPickerView setHidden:NO];
    }
}

- (void)hideFontColorPickerView {
    [self.fontColorPickerView setHidden:YES];
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
    [self.elementLayer insertSubview:self.backgroundImageView atIndex:0];
    [self.elements insertObject:self.backgroundImageView atIndex:0];
}

#pragma mark - Tool Bar Buttons
- (void)newCanvas:(GSButton *)canvasButton {
    if ([canvasButton isSelected]) {
        [self.selectedElementView deselect];
        [canvasButton setIsSelected:NO];
    } else {
        CanvasElement *canvasElement = [[CanvasElement alloc] initWithFrame:CGRectMake(0,
                                                                                       0,
                                                                                       self.frame.size.width,
                                                                                       self.frame.size.height)
                                                                      image:nil];
        [canvasElement setDelegate:self];
        [((MainPaintingView *)[canvasElement contentView]) setDelegate:self];
        [self addElement:canvasElement];
        [canvasElement select];
        [canvasButton setIsSelected:YES];
    }
}

- (void)newText:(GSButton *)textButton {
    if ([textButton isSelected]) {
        [self.selectedElementView deselect];
        [((GSButton *)[self.toolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:NO];
        [((GSButton *)[self.textToolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:NO];
    } else {
        TextElement *textElement = [[TextElement alloc] initWithFrame:CGRectMake((self.frame.size.width-kDefaultTextBoxWidth)/2, self.frame.size.height/4, kDefaultTextBoxWidth, kDefaultTextBoxHeight)];
        [textElement setDelegate:self];
        [self addElement:textElement];
        [textElement select];
        [((GSButton *)[self.toolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:YES];
        [((GSButton *)[self.textToolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:YES];
    }
}

- (void)showHistory {
    [self showHistoryView];
}

- (void)lockPage {
    
}

#pragma mark - Show Previous/Export/Next for Multiple Pages
- (void)showExportControl:(GSButton *)button {
    [self.pageCurlButton setHidden:YES];
    [self.toolLayer setHidden:YES];
    [self.textToolLayer setHidden:YES];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showExportControl:)]) {
            [self.delegate showExportControl:self];
        }
    });
}

- (void)hideExportControl {
    [self.pageCurlButton setHidden:NO];
    [self deselectAll];
    [self showToolBar];
}

- (void)doneEditing {
    [self.pageCurlButton setHidden:YES];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneEditingPage:)]) {
        [self.delegate doneEditingPage:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)selectFont {
    [self showFontPickerView];
}

- (void)selectColor {
    [self showFontColorPickerView];
}

#pragma mark - Elements Handler
- (void)addElement:(WBBaseElement *)element {
    [self.elementLayer addSubview:element];
    [self.elements addObject:element];
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

#pragma mark - Elements Delegate
- (void)deselectAll {
    for (WBBaseElement *existedElement in self.elements) {
        if (existedElement != self.selectedElementView) {
            [existedElement deselect];
        }
    }
    [self hideCanvasControl];
    [self hideHistoryView];
}

- (void)elementSelected:(WBBaseElement *)element {
    self.selectedElementView = element;
    [self deselectAll];
    
    if ([element isKindOfClass:[TextElement class]]) {
        [self showTextToolBar];
        [((GSButton *)[self.toolBarButtons objectAtIndex:kTextButtonIndex]) setIsSelected:YES];
    } else if ([element isKindOfClass:[CanvasElement class]]) {
        [self showCanvasControl];
        [((GSButton *)[self.toolBarButtons objectAtIndex:kCanvasButtonIndex]) setIsSelected:YES];
    }
}

- (void)elementDeselected:(WBBaseElement *)element {
    if ([element isKindOfClass:[TextElement class]]) {
        [self.fontPickerView setHidden:YES];
        [self.fontColorPickerView setHidden:YES];
    } else if ([element isKindOfClass:[CanvasElement class]]) {
        [self hideCanvasControl];
    }
    [self showToolBar];
}

- (void)elementCreated:(WBBaseElement *)element successful:(BOOL)successful {
    if (successful) {
        [[HistoryManager sharedManager] addActionCreateElement:element forPage:self];
    } else {
        [element removeFromSuperview];
        [self.elements removeObject:element];
    }
}

- (void)elementDeleted:(WBBaseElement *)element {
    [[HistoryManager sharedManager] addActionDeleteElement:element forPage:self];
    if ([element isKindOfClass:[TextElement class]]) {
        [self showToolBar];
    }
}

#pragma mark - Keyboard Delegate
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self showTextToolBar];
    [self hideFontPickerView];
    [self hideFontColorPickerView];
    [self hideHistoryView];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.textToolLayer.frame;
        frame.origin.y -= kbSize.height;
        self.textToolLayer.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self showToolBar];
    
    [UIView animateWithDuration:0.2f animations:^{        
        CGRect frame = self.textToolLayer.frame;
        frame.origin.y += kbSize.height;
        self.textToolLayer.frame = frame;
    }];
}

#pragma mark - Backup/Restore Save/Load
- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"page_uid"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"page_frame"];
    
    NSMutableArray *elementArray = [NSMutableArray arrayWithCapacity:[self.elements count]];
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
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.elementLayer.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *exportedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return exportedImage;
}

#pragma mark - Canvas View: Color Picker View + Color Tab View
- (void)showCanvasControl {
    [self.colorPickerView setHidden:NO];
    [self.colorTabView setHidden:NO];
    [self.undoButton setHidden:NO];
    [self.redoButton setHidden:NO];
}

- (void)hideCanvasControl {
    [self.colorPickerView setHidden:YES];
    [self.colorTabView setHidden:YES];
    [self.undoButton setHidden:YES];
    [self.redoButton setHidden:YES];
}

- (void)initColorPickerWithFrame:(CGRect)frame {
    // Bottom Color Tabs
    self.colorTabView = [[ColorTabView alloc] initWithFrame:CGRectMake(kToolBarItemWidth,
                                                                       frame.size.height-kLauncherHeight,
                                                                       frame.size.width-kToolBarItemWidth,
                                                                       kLauncherHeight)];
    [self.colorTabView setDelegate:self];
    [self insertSubview:self.colorTabView atIndex:kCanvasTabZIndex];
    [self.colorTabView setHidden:YES];
    
    // Color Picker
    self.colorPickerView = [[ColorPickerView alloc] initWithFrame:CGRectMake(0,
                                                                             frame.size.height-kLauncherHeight-kColorPickerViewHeight,
                                                                             frame.size.width,
                                                                             kColorPickerViewHeight)];
    [self.colorPickerView setDelegate:self];
    [self insertSubview:self.colorPickerView atIndex:kCanvasPickerZIndex];
    [self.colorPickerView setHidden:YES];
}

- (void)selectColorTabAtIndex:(int)index {
    [self.colorPickerView selectColorTabAtIndex:index];
}

- (void)showHidePicker {
    if ([self.colorPickerView alpha] == 0.0f) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        self.colorPickerView.alpha = 1.0f;
        self.colorPickerView.frame = CGRectMake(0,
                                                self.frame.size.height-kLauncherHeight-kColorPickerViewHeight,
                                                self.colorTabView.frame.size.width,
                                                self.colorPickerView.frame.size.height);
        [UIView commitAnimations];
        
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        self.colorPickerView.alpha = 0.0f;
        self.colorPickerView.frame = CGRectMake(0,
                                                self.frame.size.height-kLauncherHeight,
                                                self.colorTabView.frame.size.width,
                                                self.colorPickerView.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)updateSelectedColor {
    [self.colorTabView updateColorTab];
}

#pragma mark - Canvas View: Undo/Redo Button
- (void)initUndoRedoButtonsWithFrame:(CGRect)frame {
    self.undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.undoButton.frame = CGRectMake(0, 0, kURButtonWidthHeight, kURButtonWidthHeight);
    self.undoButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.undoButton addTarget:self action:@selector(undoButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.undoButton addTarget:self action:@selector(undoButtonTouchDown)
              forControlEvents:UIControlEventTouchDown];
    [self.undoButton addTarget:self action:@selector(undoButtonDragExit)
              forControlEvents:UIControlEventTouchDragExit];
    [self.undoButton addTarget:self action:@selector(undoButtonDragEnter)
              forControlEvents:UIControlEventTouchDragEnter];
    [self.undoButton setImage:[UIImage imageNamed:@"Whiteboard.bundle/URUndoButton.png"]
                     forState:UIControlStateNormal];
    [self insertSubview:self.undoButton atIndex:kCanvasUndoZIndex];
    [self.undoButton setHidden:YES];
    
    self.redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.redoButton.frame = CGRectMake(frame.size.width-kURButtonWidthHeight,
                                       0,
                                       kURButtonWidthHeight,
                                       kURButtonWidthHeight);
    self.redoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.redoButton addTarget:self action:@selector(redoButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.redoButton addTarget:self action:@selector(redoButtonTouchDown)
              forControlEvents:UIControlEventTouchDown];
    [self.redoButton addTarget:self action:@selector(redoButtonDragExit)
              forControlEvents:UIControlEventTouchDragExit];
    [self.redoButton addTarget:self action:@selector(redoButtonDragEnter)
              forControlEvents:UIControlEventTouchDragEnter];
    [self.redoButton setImage:[UIImage imageNamed:@"Whiteboard.bundle/URRedoButton.png"]
                     forState:UIControlStateNormal];
    [self insertSubview:self.redoButton atIndex:kCanvasRedoZIndex];
    [self.redoButton setHidden:YES];
    
    [self updateBar];
}

- (void) undoButtonTapped {
    [((MainPaintingView *)[self.selectedElementView contentView]) undoStroke];
    [self updateBar];
}

- (void) undoButtonTouchDown {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkUndo]) {
        self.undoButton.alpha = 0.5;
    }
}

- (void) undoButtonDragExit {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkUndo]) {
        self.undoButton.alpha = 1.0;
    }
}

- (void) undoButtonDragEnter {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkUndo]) {
        self.undoButton.alpha = 0.5;
    }
}

- (void) redoButtonTapped {
    [((MainPaintingView *)[self.selectedElementView contentView]) redoStroke];
    [self updateBar];
}

- (void) redoButtonTouchDown {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkRedo]) {
        self.redoButton.alpha = 0.5;
    }
}

- (void) redoButtonDragExit {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkRedo]) {
        self.redoButton.alpha = 1.0;
    }
}

- (void) redoButtonDragEnter {
    if ([((MainPaintingView *)[self.selectedElementView contentView]) checkRedo]) {
        self.redoButton.alpha = 0.5;
    }
}

- (void) updateBar {
    if (![((MainPaintingView *)[self.selectedElementView contentView]) checkUndo]) {
        self.undoButton.alpha = 0.2;
    } else {
        self.undoButton.alpha = 1.0;
    }
    
    if (![((MainPaintingView *)[self.selectedElementView contentView]) checkRedo]) {
        self.redoButton.alpha = 0.2;
    } else {
        self.redoButton.alpha = 1.0;
    }
}

- (void)checkUndo:(int)undoCount {
    [self updateBar];
}

- (void)checkRedo:(int)redoCount {
    [self updateBar];
}

- (void)updateBoundingRect:(CGRect)boundingRect {
    if ([self.selectedElementView isKindOfClass:[CanvasElement class]]) {
        CanvasElement *element = (CanvasElement *) self.selectedElementView;
        [element updateBoundingRect:boundingRect];
    }
}

@end
