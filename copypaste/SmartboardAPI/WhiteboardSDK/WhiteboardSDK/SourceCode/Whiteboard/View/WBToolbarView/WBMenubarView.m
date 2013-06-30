//
//  WBMenubarView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBMenubarView.h"
#import "WBMenuButton.h"
#import "WBUndoButton.h"
#import "WBHistoryButton.h"
#import <QuartzCore/QuartzCore.h>

@interface WBMenubarView () {
    WBHistoryButton *historyButton;
    WBMenuButton *menuButton;
}
@end

@implementation WBMenubarView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        
        menuButton = [[WBMenuButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:menuButton];
        
        WBUndoButton *undoButton = [[WBUndoButton alloc] initWithFrame:CGRectMake(frame.size.width/3, 0, frame.size.width/3, frame.size.height)];
        [undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:undoButton];
        
        historyButton = [[WBHistoryButton alloc] initWithFrame:CGRectMake(frame.size.width*2/3, 0, frame.size.width/3, frame.size.height)];
        [historyButton addTarget:self action:@selector(historyButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:historyButton];
    }
    return self;
}

- (void)menuButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(menuButtonTappedFrom:)]) {
        [self.delegate menuButtonTappedFrom:self];
    }
}

- (void)undoButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(performUndo)]) {
        [self.delegate performUndo];
    }
}

- (void)historyButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(historyButtonTappedFrom:)]) {
        [self.delegate historyButtonTappedFrom:self];
    }
}

- (void)didShowMenuView:(BOOL)success {
    [menuButton setSelected:success];
}

- (void)didShowHistoryView:(BOOL)success {
    [historyButton setSelected:success];
}

@end