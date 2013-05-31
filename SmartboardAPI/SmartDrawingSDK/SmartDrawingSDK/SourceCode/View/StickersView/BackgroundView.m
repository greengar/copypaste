//
//  BackgroundView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "BackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@interface BackgroundView()
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation BackgroundView
@synthesize backgroundView = _backgroundView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.allowToSelect = YES;
        self.allowToMove = NO;
        self.allowToEdit = NO;
        self.layer.borderWidth = 0;
        
        if (image) {
            self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [self.backgroundView setUserInteractionEnabled:YES];
            [self.backgroundView setContentMode:UIViewContentModeScaleToFill];
            [self.backgroundView setImage:image];
            [self addSubview:self.backgroundView];
        }
    }
    return self;
}

- (UIView *)contentView {
    return self.backgroundView;
}

- (void)select {
    // I'm background, I do nothing
}

- (void)deselect {
    // I'm background, I do nothing
}

@end
