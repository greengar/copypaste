//
//  WBUndoButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/20/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBUndoButton.h"
#import "WBUtils.h"

@implementation WBUndoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* selectedButtonGrayBackground = [UIColor clearColor];
    UIColor* selectedUndoButtonWhite = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1]; // black (stroke)
    
    // Use bitwise & operator to see whether the state is highlighted or selected
    if (self.state & UIControlStateHighlighted || self.state & UIControlStateSelected)
    {
        // ordering here is important
        UIColor* undoArrowBlackColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1]; // white
        selectedButtonGrayBackground = [UIColor colorWithRed: 0.557 green: 0.557 blue: 0.557 alpha: 1];
        selectedUndoButtonWhite = undoArrowBlackColor;
    }
    
    //// Frames
    CGRect undoButtonFrame2 = self.bounds; //CGRectMake(100, 18, 81, 74);
    
    
    //// Undo Button Group
    {
        //// Undo Button Background Rectangle 2 Drawing
        UIBezierPath* undoButtonBackgroundRectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(undoButtonFrame2), CGRectGetMinY(undoButtonFrame2), 81, 74)];
        [selectedButtonGrayBackground setFill];
        [undoButtonBackgroundRectangle2Path fill];
        
        
        //// Undo Button Circle 2 Drawing
        UIBezierPath* undoButtonCircle2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(undoButtonFrame2) + 12.5, CGRectGetMinY(undoButtonFrame2) + 8.5, 56, 56)];
        [selectedUndoButtonWhite setStroke];
        undoButtonCircle2Path.lineWidth = 1.5;
        [undoButtonCircle2Path stroke];
        
        
        //// Undo Arrow Bezier 2 Drawing
        UIBezierPath* undoArrowBezier2Path = [UIBezierPath bezierPath];
        [undoArrowBezier2Path moveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 53, CGRectGetMinY(undoButtonFrame2) + 46)];
        [undoArrowBezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 54.5, CGRectGetMinY(undoButtonFrame2) + 27.5) controlPoint1: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 53, CGRectGetMinY(undoButtonFrame2) + 46) controlPoint2: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 60.18, CGRectGetMinY(undoButtonFrame2) + 36.73)];
        [undoArrowBezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 42, CGRectGetMinY(undoButtonFrame2) + 21) controlPoint1: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 51.75, CGRectGetMinY(undoButtonFrame2) + 23.04) controlPoint2: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 46.82, CGRectGetMinY(undoButtonFrame2) + 20.68)];
        [undoArrowBezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 29.5, CGRectGetMinY(undoButtonFrame2) + 27.5) controlPoint1: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 36.85, CGRectGetMinY(undoButtonFrame2) + 21.34) controlPoint2: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 31.82, CGRectGetMinY(undoButtonFrame2) + 24.63)];
        [undoArrowBezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 29.5, CGRectGetMinY(undoButtonFrame2) + 33.5) controlPoint1: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 25.01, CGRectGetMinY(undoButtonFrame2) + 33.05) controlPoint2: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 29.5, CGRectGetMinY(undoButtonFrame2) + 33.46)];
        [selectedUndoButtonWhite setStroke];
        undoArrowBezier2Path.lineWidth = 2;
        [undoArrowBezier2Path stroke];
        
        
        //// Undo Arrow Tip 2 Drawing
        UIBezierPath* undoArrowTip2Path = [UIBezierPath bezierPath];
        [undoArrowTip2Path moveToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 23, CGRectGetMinY(undoButtonFrame2) + 29)];
        [undoArrowTip2Path addLineToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 31, CGRectGetMinY(undoButtonFrame2) + 35)];
        [undoArrowTip2Path addLineToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 23, CGRectGetMinY(undoButtonFrame2) + 38)];
        [undoArrowTip2Path addLineToPoint: CGPointMake(CGRectGetMinX(undoButtonFrame2) + 23, CGRectGetMinY(undoButtonFrame2) + 29)];
        [undoArrowTip2Path closePath];
        [selectedUndoButtonWhite setFill];
        [undoArrowTip2Path fill];
        [selectedUndoButtonWhite setStroke];
        undoArrowTip2Path.lineWidth = 2;
        [undoArrowTip2Path stroke];
    }
    
    

}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return _(@"Undo"); // requires WBUtils
}

/* This custom view behaves like a button. */
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint
{
    return _(@"Steps back one action");
}

@end
