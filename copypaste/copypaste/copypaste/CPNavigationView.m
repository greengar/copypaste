//
//  CPNavigationView.m
//  copypaste
//
//  Created by Hector Zhao on 5/2/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPNavigationView.h"
#import <Smartboard/Smartboard.h>

@implementation CPNavigationView
@synthesize delegate= _delegate;

- (id)initWithFrame:(CGRect)frame hasBack:(BOOL)back hasDone:(BOOL)done
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (back) {
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
            [backButton setTitle:@"back" forState:UIControlStateNormal];
            [backButton.titleLabel setTextColor:[UIColor whiteColor]];
            [backButton.titleLabel setShadowColor:[UIColor blackColor]];
            [backButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [backButton setBackgroundColor:kCPLightOrangeColor];
            [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:backButton];
        }
        
        if (done) {
            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [doneButton setFrame:CGRectMake(frame.size.width-frame.size.height, 0, frame.size.height, frame.size.height)];
            [doneButton setTitle:@"done" forState:UIControlStateNormal];
            [doneButton.titleLabel setTextColor:[UIColor whiteColor]];
            [doneButton.titleLabel setShadowColor:[UIColor blackColor]];
            [doneButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            [doneButton setBackgroundColor:kCPPasteTextColor];
            [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:doneButton];
        }
    
    }
    return self;
}
    
- (void)backButtonTapped:(id)sender {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(backButtonTapped)]) {
        [self.delegate backButtonTapped];
    }
}

- (void)doneButtonTapped:(id)sender {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneButtonTapped)]) {
        [self.delegate doneButtonTapped];
    }
}

@end
