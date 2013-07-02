//
//  MySlider.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/25/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setMinimumTrackTintColor:[UIColor darkGrayColor]];
        [self setThumbTintColor:[UIColor whiteColor]];
    }
    return self;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
	CGRect bounds = self.bounds;
	bounds = CGRectInset(bounds, -10, -3);
	return CGRectContainsPoint(bounds, point);
}

- (void)setMinimumTitle:(NSString *)minTitle {
    UILabel *minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -10, self.frame.size.width/2, self.frame.size.height/2)];
    [minLabel setText:minTitle];
    [minLabel setTextAlignment:NSTextAlignmentLeft];
    [minLabel setBackgroundColor:[UIColor clearColor]];
    [minLabel setTextColor:[UIColor darkGrayColor]];
    [minLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [self addSubview:minLabel];
}

- (void)setMaximumTitle:(NSString *)maxTitle {
    UILabel *maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, -10, self.frame.size.width/2, self.frame.size.height/2)];
    [maxLabel setText:maxTitle];
    [maxLabel setTextAlignment:NSTextAlignmentRight];
    [maxLabel setBackgroundColor:[UIColor clearColor]];
    [maxLabel setTextColor:[UIColor darkGrayColor]];
    [maxLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [self addSubview:maxLabel];
}

- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
	return YES;
}

@end
