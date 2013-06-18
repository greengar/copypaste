//
//  WBButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBButton.h"

@interface WBButton ()
{
    BOOL tap;
}
@end

@implementation WBButton

static inline float radians(double degrees) { return degrees * M_PI / 180; };

#pragma mark - UIControl

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)value
{
    [super setHighlighted:value];
    
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)value
{
    [super setSelected:value];
    
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.radius = 10;
        
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tap = YES;
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    tap = NO;
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    float distance = 70.0;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGRect testRect = CGRectMake(-distance, -distance, self.frame.size.width + distance * 2, self.frame.size.height + distance * 2);
    if (CGRectContainsPoint(testRect, touchPoint)) {
        tap = YES;
        [self setNeedsDisplay];
    }
    else {
        tap = NO;
        [self setNeedsDisplay];
    }
    [super touchesMoved:touches withEvent:event];
}

@end
