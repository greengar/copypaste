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

@implementation SDPage
@synthesize uid = _uid;
@synthesize elementViews = _elementViews;
@synthesize selectedElementView = _selectedElementView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.uid = [SDUtils getCurrentTime];
        
        self.elementViews = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *canvasButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [canvasButton setTitle:@"Canvas" forState:UIControlStateNormal];
        [canvasButton setFrame:CGRectMake(0, 0, 80, 44)];
        [canvasButton addTarget:self action:@selector(newCanvas) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:canvasButton];
        
        UIButton *textButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [textButton setTitle:@"Text" forState:UIControlStateNormal];
        [textButton setFrame:CGRectMake(80, 0, 80, 44)];
        [textButton addTarget:self action:@selector(newText) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:textButton];
    }
    return self;
}

- (void)select {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pageSelected:)]) {
        [self.delegate pageSelected:self];
    }
}

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
