//
//  WBMoveButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBMoveButton.h"
#import "WBUtils.h"

@implementation WBMoveButton

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
    CGRect moveButtonGroupFrame = self.bounds;
    
    
    //// Move Button Group
    {
        //// Move Button Background Rectangle Drawing
        UIBezierPath* moveButtonBackgroundRectanglePath = [UIBezierPath bezierPath];
        [moveButtonBackgroundRectanglePath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame), CGRectGetMinY(moveButtonGroupFrame) + 74)];
        [moveButtonBackgroundRectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 76, CGRectGetMinY(moveButtonGroupFrame) + 74) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame), CGRectGetMinY(moveButtonGroupFrame) + 74) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 73.19, CGRectGetMinY(moveButtonGroupFrame) + 74)];
        [moveButtonBackgroundRectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 69.15) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 78.81, CGRectGetMinY(moveButtonGroupFrame) + 74) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 71.99)];
        [moveButtonBackgroundRectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 5.23) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 66.32) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 8.02)];
        [moveButtonBackgroundRectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 76, CGRectGetMinY(moveButtonGroupFrame)) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 81, CGRectGetMinY(moveButtonGroupFrame) + 2.43) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 78.8, CGRectGetMinY(moveButtonGroupFrame))];
        [moveButtonBackgroundRectanglePath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame), CGRectGetMinY(moveButtonGroupFrame)) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 73.2, CGRectGetMinY(moveButtonGroupFrame)) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame), CGRectGetMinY(moveButtonGroupFrame))];
        [moveButtonBackgroundRectanglePath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame), CGRectGetMinY(moveButtonGroupFrame) + 74)];
        [moveButtonBackgroundRectanglePath closePath];
        [selectedButtonGrayBackground setFill];
        [moveButtonBackgroundRectanglePath fill];
        
        
        //// Move Button Circle Drawing
        UIBezierPath* moveButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(moveButtonGroupFrame) + 12.5, CGRectGetMinY(moveButtonGroupFrame) + 9, 56, 56)];
        [selectedUndoButtonWhite setStroke];
        moveButtonCirclePath.lineWidth = 1.5;
        [moveButtonCirclePath stroke];
        
        
        //// Up Arrow in Move Button Drawing
        UIBezierPath* upArrowInMoveButtonPath = [UIBezierPath bezierPath];
        [upArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 33.5, CGRectGetMinY(moveButtonGroupFrame) + 27)];
        [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 47.5, CGRectGetMinY(moveButtonGroupFrame) + 27)];
        [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 40.5, CGRectGetMinY(moveButtonGroupFrame) + 20)];
        [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 33.5, CGRectGetMinY(moveButtonGroupFrame) + 27)];
        [upArrowInMoveButtonPath closePath];
        [selectedUndoButtonWhite setStroke];
        upArrowInMoveButtonPath.lineWidth = 1.5;
        [upArrowInMoveButtonPath stroke];
        
        
        //// Down Arrow in Move Button Drawing
        UIBezierPath* downArrowInMoveButtonPath = [UIBezierPath bezierPath];
        [downArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 33.5, CGRectGetMinY(moveButtonGroupFrame) + 47)];
        [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 47.5, CGRectGetMinY(moveButtonGroupFrame) + 47)];
        [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 40.5, CGRectGetMinY(moveButtonGroupFrame) + 54)];
        [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 33.5, CGRectGetMinY(moveButtonGroupFrame) + 47)];
        [downArrowInMoveButtonPath closePath];
        [selectedUndoButtonWhite setStroke];
        downArrowInMoveButtonPath.lineWidth = 1.5;
        [downArrowInMoveButtonPath stroke];
        
        
        //// Left Arrow in Move Button Drawing
        UIBezierPath* leftArrowInMoveButtonPath = [UIBezierPath bezierPath];
        [leftArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30.5, CGRectGetMinY(moveButtonGroupFrame) + 30)];
        [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30.5, CGRectGetMinY(moveButtonGroupFrame) + 44)];
        [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 23.5, CGRectGetMinY(moveButtonGroupFrame) + 36)];
        [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30.5, CGRectGetMinY(moveButtonGroupFrame) + 30)];
        [leftArrowInMoveButtonPath closePath];
        [selectedUndoButtonWhite setStroke];
        leftArrowInMoveButtonPath.lineWidth = 1.5;
        [leftArrowInMoveButtonPath stroke];
        
        
        //// Right Arrow in Move Button Drawing
        UIBezierPath* rightArrowInMoveButtonPath = [UIBezierPath bezierPath];
        [rightArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 50.5, CGRectGetMinY(moveButtonGroupFrame) + 30)];
        [rightArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 50.5, CGRectGetMinY(moveButtonGroupFrame) + 44)];
        [rightArrowInMoveButtonPath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 57.49, CGRectGetMinY(moveButtonGroupFrame) + 37.54) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 50.5, CGRectGetMinY(moveButtonGroupFrame) + 44) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 57.15, CGRectGetMinY(moveButtonGroupFrame) + 37.85)];
        [rightArrowInMoveButtonPath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 50.5, CGRectGetMinY(moveButtonGroupFrame) + 30) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 57.83, CGRectGetMinY(moveButtonGroupFrame) + 37.23) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 50.5, CGRectGetMinY(moveButtonGroupFrame) + 30)];
        [rightArrowInMoveButtonPath closePath];
        [selectedUndoButtonWhite setStroke];
        rightArrowInMoveButtonPath.lineWidth = 1.5;
        [rightArrowInMoveButtonPath stroke];
        
        
        //// Small Circle in Move Button Drawing
        UIBezierPath* smallCircleInMoveButtonPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(moveButtonGroupFrame) + 37, CGRectGetMinY(moveButtonGroupFrame) + 33.5, 7, 7)];
        [selectedUndoButtonWhite setStroke];
        smallCircleInMoveButtonPath.lineWidth = 1.5;
        [smallCircleInMoveButtonPath stroke];
    }
    
    

}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return _(@"Move Mode"); // requires WBUtils
}

/* This custom view behaves like a button. */
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint
{
    return _(@"Activates Move Mode in which you can move Objects on the Page");
}

@end
