//
//  WBAddMoreButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBAddMoreButton.h"
#import "WBUtils.h"

@implementation WBAddMoreButton

+ (CGSize)preferredSize
{
    return CGSizeMake(81, 74);
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
    CGRect addButtonFrame = self.bounds; //CGRectMake(729, 669, 81, 74);
    
    
    //// Add Button Group
    {
        //// Add Button Background Rectangle Drawing
        UIBezierPath* addButtonBackgroundRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(addButtonFrame), CGRectGetMinY(addButtonFrame), 81, 74)];
        [selectedButtonGrayBackground setFill];
        [addButtonBackgroundRectanglePath fill];
        
        
        //// Add Button Circle Drawing
        UIBezierPath* addButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(addButtonFrame) + 12.5, CGRectGetMinY(addButtonFrame) + 8.5, 56, 56)];
        [selectedUndoButtonWhite setStroke];
        addButtonCirclePath.lineWidth = 1.5;
        [addButtonCirclePath stroke];
        
        
        //// Vertical Bar in Add Button Drawing
        UIBezierPath* verticalBarInAddButtonPath = [UIBezierPath bezierPath];
        [verticalBarInAddButtonPath moveToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 41, CGRectGetMinY(addButtonFrame) + 19)];
        [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 41, CGRectGetMinY(addButtonFrame) + 37.57)];
        [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 41, CGRectGetMinY(addButtonFrame) + 54)];
        [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 41, CGRectGetMinY(addButtonFrame) + 54)];
        [selectedUndoButtonWhite setStroke];
        verticalBarInAddButtonPath.lineWidth = 2;
        [verticalBarInAddButtonPath stroke];
        
        
        //// Horizontal Bar in Add Button Drawing
        UIBezierPath* horizontalBarInAddButtonPath = [UIBezierPath bezierPath];
        [horizontalBarInAddButtonPath moveToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 24, CGRectGetMinY(addButtonFrame) + 36)];
        [horizontalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 40.53, CGRectGetMinY(addButtonFrame) + 36)];
        [horizontalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(addButtonFrame) + 58, CGRectGetMinY(addButtonFrame) + 36)];
        [selectedUndoButtonWhite setStroke];
        horizontalBarInAddButtonPath.lineWidth = 2;
        [horizontalBarInAddButtonPath stroke];
    }
    
    
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return _(@"Add"); // requires WBUtils
}

/* This custom view behaves like a button. */
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint
{
    return _(@"Opens Add popover with items like Add Text");
}

@end
