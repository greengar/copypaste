//
//  StickersView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "StickersView.h"

@interface StickersView()
@property (nonatomic, strong) UIImageView *stickerView;
@end

@implementation StickersView
@synthesize stickerView = _stickerView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        if (image) {
            self.stickerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [self.stickerView setUserInteractionEnabled:YES];
            [self.stickerView setContentMode:UIViewContentModeScaleToFill];
            [self.stickerView setImage:image];
            [self addSubview:self.stickerView];
        }
    }
    return self;
}

- (UIView *)contentView {
    return self.stickerView;
}

@end
