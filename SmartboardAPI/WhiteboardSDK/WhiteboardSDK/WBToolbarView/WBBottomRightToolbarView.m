//
//  WBBottomRightToolbarView.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBottomRightToolbarView.h"

@interface WBBottomRightToolbarView()
@property (nonatomic, strong) WBAddMoreButton *addMoreButton;
@property (nonatomic, strong) WBMoveButton *moveButton;
@end

@implementation WBBottomRightToolbarView
@synthesize addMoreButton = _addMoreButton;
@synthesize moveButton = _moveButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        
        self.addMoreButton = [[WBAddMoreButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, frame.size.height)];
        self.addMoreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.addMoreButton addTarget:self action:@selector(addMore:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.addMoreButton];
        
        self.moveButton = [[WBMoveButton alloc] initWithFrame:CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height)];
        self.moveButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.moveButton addTarget:self action:@selector(enableMove:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.moveButton];
    }
    return self;
}

- (void)addMore:(WBAddMoreButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(addMoreButtonTapped)]) {
        [self.delegate addMoreButtonTapped];
    }
}

- (void)enableMove:(WBMoveButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(moveButtonTapped)]) {
        [self.delegate moveButtonTapped];
    }
}

- (void)didShowAddMoreView:(BOOL)success {
    [self.addMoreButton setSelected:success];
}

- (void)didActivatedMove:(BOOL)success {
    [self.moveButton setSelected:success];
}

@end
