//
//  WBMenubarView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBMenubarView.h"
#import <QuartzCore/QuartzCore.h>

@interface WBMenubarView()
@property (nonatomic, strong) UIButton *historyButton;
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
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [menuButton setFrame:CGRectMake(0, 0, frame.size.width/3, frame.size.height)];
        [menuButton setTitle:@"Menu" forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:menuButton];
        
        UIButton *undoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [undoButton setFrame:CGRectMake(frame.size.width/3, 0, frame.size.width/3, frame.size.height)];
        [undoButton setTitle:@"Undo" forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(undoButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:undoButton];
        
        self.historyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.historyButton setFrame:CGRectMake(frame.size.width*2/3, 0, frame.size.width/3, frame.size.height)];
        [self.historyButton setTitle:@"History" forState:UIControlStateNormal];
        [self.historyButton addTarget:self action:@selector(historyButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.historyButton];
    }
    return self;
}

- (void)menuButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showMenu)]) {
        [self.delegate showMenu];
    }
}

- (void)undoButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(performUndo)]) {
        [self.delegate performUndo];
    }
}

- (void)historyButtonTapped:(UIButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showHistory:from:)]) {
        [self.delegate showHistory:!button.isSelected from:self];
    }
    [button setSelected:!button.isSelected];
}

- (void)historyClosed {
    [self.historyButton setSelected:NO];
}

@end