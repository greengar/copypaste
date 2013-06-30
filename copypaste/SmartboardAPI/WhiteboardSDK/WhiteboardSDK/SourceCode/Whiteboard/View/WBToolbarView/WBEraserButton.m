//
//  WBEraserButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBEraserButton.h"

@implementation WBEraserButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)preferredSize
{
    return CGSizeMake(61, 61);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* blackCircleButtonOutline = [UIColor colorWithRed: 0.157 green: 0.157 blue: 0.157 alpha: 1];
    UIColor* whiteCircleButtonFill = [UIColor colorWithRed: 0.996 green: 0.996 blue: 0.996 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1]; //black
    UIColor* eraserWhiteColor = [UIColor colorWithRed: 0.988 green: 0.988 blue: 0.988 alpha: 1];
    UIColor* eraserBlackColor = [UIColor colorWithRed: 0.145 green: 0.145 blue: 0.145 alpha: 1];
    
    // Use bitwise & operator to see whether the state is highlighted or selected
    if (self.state & UIControlStateHighlighted || self.state & UIControlStateSelected)
    {
        strokeColor = whiteCircleButtonFill;
        whiteCircleButtonFill = eraserBlackColor;
        
//        blackCircleButtonOutline = whiteCircleButtonFill;
//        
//        CGFloat currentBrushColorRGBA[4];
//        [currentBrushColor getRed: &currentBrushColorRGBA[0] green: &currentBrushColorRGBA[1] blue: &currentBrushColorRGBA[2] alpha: &currentBrushColorRGBA[3]];
//        
//        currentBrushColor = [UIColor colorWithRed: (currentBrushColorRGBA[0] * 0.5 + 0.5) green: (currentBrushColorRGBA[1] * 0.5 + 0.5) blue: (currentBrushColorRGBA[2] * 0.5 + 0.5) alpha: (currentBrushColorRGBA[3] * 0.5 + 0.5)];
        
    }
    
    //// Frames
    CGRect frame = self.bounds; //CGRectMake(754, 489, 61, 61);
    
    
    //// Eraser Button Group
    {
        //// Eraser Button Circle Drawing
        UIBezierPath* eraserButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 2.5, CGRectGetMinY(frame) + 2.5, 56, 56)];
        [whiteCircleButtonFill setFill];
        [eraserButtonCirclePath fill];
        [blackCircleButtonOutline setStroke];
        eraserButtonCirclePath.lineWidth = 2;
        [eraserButtonCirclePath stroke];
        
        
        //// Eraser Outline Bezier Drawing
        UIBezierPath* eraserOutlineBezierPath = [UIBezierPath bezierPath];
        [eraserOutlineBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 20.5, CGRectGetMinY(frame) + 33.5)];
        [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 16.5)];
        [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 46, CGRectGetMinY(frame) + 26)];
        [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31.5, CGRectGetMinY(frame) + 40.5)];
        [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 26.5, CGRectGetMinY(frame) + 40.5)];
        [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 20.5, CGRectGetMinY(frame) + 33.5)];
        [eraserOutlineBezierPath closePath];
        [eraserWhiteColor setFill];
        [eraserOutlineBezierPath fill];
        [strokeColor setStroke];
        eraserOutlineBezierPath.lineWidth = 1.5;
        [eraserOutlineBezierPath stroke];
        
        
        //// Eraser Black Area Bezier Drawing
        UIBezierPath* eraserBlackAreaBezierPath = [UIBezierPath bezierPath];
        [eraserBlackAreaBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 28, CGRectGetMinY(frame) + 26)];
        [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 37.5, CGRectGetMinY(frame) + 35.5)];
        [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 46.5, CGRectGetMinY(frame) + 26.5)];
        [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 16.5)];
        [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28, CGRectGetMinY(frame) + 26)];
        [eraserBlackAreaBezierPath closePath];
        [eraserBlackColor setFill];
        [eraserBlackAreaBezierPath fill];
        
        
        //// Eraser Line Bezier Drawing
        UIBezierPath* eraserLineBezierPath = [UIBezierPath bezierPath];
        [eraserLineBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 44)];
        [eraserLineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 35.5, CGRectGetMinY(frame) + 44)];
        [eraserBlackColor setFill];
        [eraserLineBezierPath fill];
        [strokeColor setStroke];
        eraserLineBezierPath.lineWidth = 2;
        [eraserLineBezierPath stroke];
    }
    
    

}

@end
