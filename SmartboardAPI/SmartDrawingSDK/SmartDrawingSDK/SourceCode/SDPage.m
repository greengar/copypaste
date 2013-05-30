//
//  SDPage.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDPage.h"
#import "CanvasView.h"
#import "TextView.h"
#import "SDUtils.h"

#define kToolBarItemWidth   (frame.size.width/5)
#define kToolBarItemHeight  44
#define kCanvasButtonIndex  0
#define kTextButtonIndex    (kCanvasButtonIndex+1)
#define kHistoryButtonIndex (kCanvasButtonIndex+2)
#define kLockButtonIndex    (kCanvasButtonIndex+3)
#define kDoneButtonIndex    (kCanvasButtonIndex+4)

@interface SDPage()
@property (nonatomic, strong) NSMutableArray *toolBarButtons;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation SDPage
@synthesize uid = _uid;
@synthesize toolBarButtons = _toolBarButtons;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize elementViews = _elementViews;
@synthesize selectedElementView = _selectedElementView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.uid = [SDUtils generateUniqueId];
        
        self.toolBarButtons = [[NSMutableArray alloc] init];
        self.elementViews = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *canvasButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [canvasButton setTitle:@"Canvas" forState:UIControlStateNormal];
        [canvasButton setFrame:CGRectMake(0, frame.size.height-kToolBarItemHeight, kToolBarItemWidth, kToolBarItemHeight)];
        [canvasButton addTarget:self action:@selector(newCanvas) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:canvasButton];
        [self.toolBarButtons addObject:canvasButton];
        
        UIButton *textButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [textButton setTitle:@"Text" forState:UIControlStateNormal];
        [textButton setFrame:CGRectMake(kToolBarItemWidth, frame.size.height-kToolBarItemHeight, kToolBarItemWidth, kToolBarItemHeight)];
        [textButton addTarget:self action:@selector(newText) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:textButton];
        [self.toolBarButtons addObject:textButton];
        
        UIButton *historyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [historyButton setTitle:@"History" forState:UIControlStateNormal];
        [historyButton setFrame:CGRectMake(kToolBarItemWidth*2, frame.size.height-kToolBarItemHeight, kToolBarItemWidth, kToolBarItemHeight)];
        [historyButton addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:historyButton];
        [self.toolBarButtons addObject:historyButton];
        
        UIButton *lockButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [lockButton setTitle:@"Lock" forState:UIControlStateNormal];
        [lockButton setFrame:CGRectMake(kToolBarItemWidth*3, frame.size.height-kToolBarItemHeight, kToolBarItemWidth, kToolBarItemHeight)];
        [lockButton addTarget:self action:@selector(lockPage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:lockButton];
        [self.toolBarButtons addObject:lockButton];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton setFrame:CGRectMake(kToolBarItemWidth*4, frame.size.height-kToolBarItemHeight, kToolBarItemWidth, kToolBarItemHeight)];
        [doneButton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        [self.toolBarButtons addObject:doneButton];
    }
    return self;
}

#pragma mark - Delegates back to super
- (void)select {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageSelected:)]) {
        [self.delegate pageSelected:self];
    }
}

#pragma mark - Background image
- (void)setBackgroundImage:(UIImage *)image {
    if (image) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self.backgroundImageView setImage:image];
        [self addSubview:self.backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
    }
}

#pragma mark - Tool Bar Buttons
- (void)newCanvas {
    CanvasView *canvasView = [[CanvasView alloc] initWithFrame:self.frame image:nil];
    [canvasView setDelegate:self];
    [self addSubview:canvasView];
    [self.elementViews addObject:canvasView];
    
    self.selectedElementView = canvasView;
}

- (void)newText {
    TextView *textView = [[TextView alloc] initWithFrame:CGRectMake(30, 100, 200, 44)];
    [textView setDelegate:self];
    [self addSubview:textView];
    [self.elementViews addObject:textView];
    
    self.selectedElementView = textView;
}

- (void)showHistory {
    
}

- (void)lockPage {
    
}

- (void)doneEditing {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneEditingPage:)]) {
        [self.delegate doneEditingPage:self];
    }
}

#pragma mark - Elements Delegate
- (void)elementSelected:(SDBaseView *)element {
    for (SDBaseView *existedElement in self.elementViews) {
        if ([element.uid isEqualToString:existedElement.uid]) {
            self.selectedElementView = element;
            [[self.selectedElementView superview] bringSubviewToFront:self.selectedElementView];
            break;
        }
    }
}

- (void)elementExited:(SDBaseView *)element {
    [element removeFromSuperview];
}

@end
