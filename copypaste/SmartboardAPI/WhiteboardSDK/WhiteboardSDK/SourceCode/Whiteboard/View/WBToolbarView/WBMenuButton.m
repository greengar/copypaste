//
//  WBMenuButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/19/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBMenuButton.h"
#import "WBUtils.h"

@implementation WBMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    CGRect menuButtonFrame = self.bounds; //CGRectMake(19, 18, 81, 74);
    
    
    //// Menu Button Group
    {
        //// Menu Button Background Rectangle Drawing
        UIBezierPath* menuButtonBackgroundRectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(menuButtonFrame), CGRectGetMinY(menuButtonFrame), 81, 74)];
        [selectedButtonGrayBackground setFill];
        [menuButtonBackgroundRectanglePath fill];
        
        
        //// Menu Button Circle Drawing
        UIBezierPath* menuButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(menuButtonFrame) + 11.5, CGRectGetMinY(menuButtonFrame) + 8.5, 56, 56)];
        [selectedUndoButtonWhite setStroke];
        menuButtonCirclePath.lineWidth = 1.5;
        [menuButtonCirclePath stroke];
        
        
        //// Menu Top Line Drawing
        UIBezierPath* menuTopLinePath = [UIBezierPath bezierPath];
        [menuTopLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 26.5)];
        [menuTopLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 26.5)];
        menuTopLinePath.lineCapStyle = kCGLineCapRound;
        
        [selectedUndoButtonWhite setStroke];
        menuTopLinePath.lineWidth = 3;
        [menuTopLinePath stroke];
        
        
        //// Menu Middle Line Drawing
        UIBezierPath* menuMiddleLinePath = [UIBezierPath bezierPath];
        [menuMiddleLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 37.5)];
        [menuMiddleLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 37.5)];
        menuMiddleLinePath.lineCapStyle = kCGLineCapRound;
        
        [selectedUndoButtonWhite setStroke];
        menuMiddleLinePath.lineWidth = 3;
        [menuMiddleLinePath stroke];
        
        
        //// Menu Button Line Drawing
        UIBezierPath* menuButtonLinePath = [UIBezierPath bezierPath];
        [menuButtonLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 47.5)];
        [menuButtonLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 47.5)];
        menuButtonLinePath.lineCapStyle = kCGLineCapRound;
        
        [selectedUndoButtonWhite setStroke];
        menuButtonLinePath.lineWidth = 3;
        [menuButtonLinePath stroke];
    }
    
    

}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return _(@"Menu"); // requires WBUtils
}

/* This custom view behaves like a button. */
- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (NSString *)accessibilityHint
{
    return _(@"Opens Menu popover with items like Back to Organizer");
}

@end
