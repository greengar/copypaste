//
//  WBHistoryButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/20/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBHistoryButton.h"
#import "WBUtils.h"

@implementation WBHistoryButton

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
        selectedButtonGrayBackground = [UIColor colorWithRed: 0.557 green: 0.557 blue: 0.557 alpha: 1]; // gray
        selectedUndoButtonWhite = undoArrowBlackColor;
    }
    
    //// Frames
    CGRect historyButtonFrame = self.bounds; //CGRectMake(181, 18, 81, 74);
    
    //// History Button Group
    {
        //// History Button Background Rectangle Drawing
        UIBezierPath* historyButtonBackgroundRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(historyButtonFrame), CGRectGetMinY(historyButtonFrame), 81, 74)];
        [selectedButtonGrayBackground setFill];
        [historyButtonBackgroundRectanglePath fill];
        
        
        //// History Button Circle Drawing
        UIBezierPath* historyButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(historyButtonFrame) + 12.5, CGRectGetMinY(historyButtonFrame) + 8.5, 56, 56)];
        [selectedUndoButtonWhite setStroke];
        historyButtonCirclePath.lineWidth = 1.5;
        [historyButtonCirclePath stroke];
        
        
        //// History Clock Bezier Drawing
        UIBezierPath* historyClockBezierPath = [UIBezierPath bezierPath];
        [historyClockBezierPath moveToPoint: CGPointMake(CGRectGetMinX(historyButtonFrame) + 41, CGRectGetMinY(historyButtonFrame) + 13)];
        [historyClockBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(historyButtonFrame) + 41, CGRectGetMinY(historyButtonFrame) + 38)];
        [historyClockBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(historyButtonFrame) + 28, CGRectGetMinY(historyButtonFrame) + 38)];
        [selectedUndoButtonWhite setStroke];
        historyClockBezierPath.lineWidth = 2;
        [historyClockBezierPath stroke];
    }
    
    

}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return _(@"History"); // requires WBUtils
}

/* This custom view behaves like a button. */
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint
{
    return _(@"Opens History popover with table of previous actions");
}

@end
