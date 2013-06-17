//
//  WBCanvasButton.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasButton.h"

@interface WBCanvasButton ()
{
    BOOL tap;
}
@end

@implementation WBCanvasButton

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

- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
//    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* currentBrushColor = [UIColor colorWithRed: 0.831 green: 0.137 blue: 0.329 alpha: 1];
    
    
    if (self.state == UIControlStateHighlighted)
    {
        CGFloat currentBrushColorRGBA[4];
        [currentBrushColor getRed: &currentBrushColorRGBA[0] green: &currentBrushColorRGBA[1] blue: &currentBrushColorRGBA[2] alpha: &currentBrushColorRGBA[3]];
        
        currentBrushColor = [UIColor colorWithRed: (currentBrushColorRGBA[0] * 0.5 + 0.5) green: (currentBrushColorRGBA[1] * 0.5 + 0.5) blue: (currentBrushColorRGBA[2] * 0.5 + 0.5) alpha: (currentBrushColorRGBA[3] * 0.5 + 0.5)];
        
    }
    
    
//    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
//    UIColor* lightGrayOutlineColor = [UIColor colorWithRed: 0.757 green: 0.757 blue: 0.757 alpha: 1];
//    UIColor* yellowFillColor = [UIColor colorWithRed: 0.847 green: 0.796 blue: 0.188 alpha: 1];
    
    
    //// Subframes
    CGRect canvasButtonFrame = self.bounds; //CGRectMake(CGRectGetMinX(bottomToolbarFrame) + 364, CGRectGetMinY(bottomToolbarFrame) - 1, 80, 75);
    
    
    //// Group
    {
        //// Selected Brush Square Background Drawing
        UIBezierPath* selectedBrushSquareBackgroundPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(canvasButtonFrame) + 0.5, CGRectGetMinY(canvasButtonFrame) + 0.5, 79, 74)];
        [currentBrushColor setFill];
        [selectedBrushSquareBackgroundPath fill];
        
        
        //// Selected Brush Circle Button Drawing
        UIBezierPath* selectedBrushCircleButtonPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(canvasButtonFrame) + 12.5, CGRectGetMinY(canvasButtonFrame) + 9.5, 56, 56)];
        [selectedButtonOutlineWhite setStroke];
        selectedBrushCircleButtonPath.lineWidth = 1;
        [selectedBrushCircleButtonPath stroke];
        
        
        //// Pencil Tip Drawing
        UIBezierPath* pencilTipPath = [UIBezierPath bezierPath];
        [pencilTipPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 28, CGRectGetMinY(canvasButtonFrame) + 45)];
        [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 25, CGRectGetMinY(canvasButtonFrame) + 54)];
        [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 34, CGRectGetMinY(canvasButtonFrame) + 51)];
        [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 28, CGRectGetMinY(canvasButtonFrame) + 45)];
        [pencilTipPath closePath];
        [selectedButtonOutlineWhite setFill];
        [pencilTipPath fill];
        
        
        //// Pencil Body Drawing
        UIBezierPath* pencilBodyPath = [UIBezierPath bezierPath];
        [pencilBodyPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 30, CGRectGetMinY(canvasButtonFrame) + 44)];
        [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 35.5, CGRectGetMinY(canvasButtonFrame) + 49.5)];
        [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 52, CGRectGetMinY(canvasButtonFrame) + 33)];
        [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 46, CGRectGetMinY(canvasButtonFrame) + 27)];
        [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 30, CGRectGetMinY(canvasButtonFrame) + 44)];
        [pencilBodyPath closePath];
        [selectedButtonOutlineWhite setFill];
        [pencilBodyPath fill];
        
        
        //// Pencil Eraser Drawing
        UIBezierPath* pencilEraserPath = [UIBezierPath bezierPath];
        [pencilEraserPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 47.5, CGRectGetMinY(canvasButtonFrame) + 25.5)];
        [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 51.5, CGRectGetMinY(canvasButtonFrame) + 21.5)];
        [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 57.5, CGRectGetMinY(canvasButtonFrame) + 27.5)];
        [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 53.5, CGRectGetMinY(canvasButtonFrame) + 31.5)];
        [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 47.5, CGRectGetMinY(canvasButtonFrame) + 25.5)];
        [pencilEraserPath closePath];
        [selectedButtonOutlineWhite setFill];
        [pencilEraserPath fill];
        
        
        //// Top Arrow Tip Drawing
        UIBezierPath* topArrowTipPath = [UIBezierPath bezierPath];
        [topArrowTipPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 36.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
        [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 44.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
        [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 40.5, CGRectGetMinY(canvasButtonFrame) + 2.5)];
        [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 36.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
        [topArrowTipPath closePath];
        [selectedButtonOutlineWhite setFill];
        [topArrowTipPath fill];
        
        
    }
    
    
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
