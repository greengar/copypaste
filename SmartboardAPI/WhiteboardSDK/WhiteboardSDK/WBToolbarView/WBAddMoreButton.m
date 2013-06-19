//
//  WBAddMoreButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBAddMoreButton.h"

@implementation WBAddMoreButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* blackCircleButtonOutline = [UIColor colorWithRed: 0.157 green: 0.157 blue: 0.157 alpha: 1];
    UIColor* whiteCircleButtonFill = [UIColor colorWithRed: 0.996 green: 0.996 blue: 0.996 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1]; // horizontal bar (black)
    
    // Use bitwise & operator to see whether the state is highlighted or selected
    if (self.state & UIControlStateHighlighted || self.state & UIControlStateSelected)
    {
        // ordering here is important
        UIColor* blackCircleButtonOutlineTemp = [blackCircleButtonOutline copy];
        blackCircleButtonOutline = whiteCircleButtonFill;
        strokeColor = whiteCircleButtonFill;
        whiteCircleButtonFill = blackCircleButtonOutlineTemp;
        
    }
    
    //// Frames
    CGRect bottomRightButtonsFrame = self.bounds; //CGRectMake(729, 668, 156, 75);
    
    
    //// Bottom Right Toolbar Tray
    {
        //// Add Button Group
        {
            //// Add Button Circle Drawing
            UIBezierPath* addButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(bottomRightButtonsFrame) + 12.5, CGRectGetMinY(bottomRightButtonsFrame) + 9.5, 56, 56)];
            [whiteCircleButtonFill setFill];
            [addButtonCirclePath fill];
            [blackCircleButtonOutline setStroke];
            addButtonCirclePath.lineWidth = 2;
            [addButtonCirclePath stroke];
            
            
            //// Vertical Bar in Add Button Drawing
            UIBezierPath* verticalBarInAddButtonPath = [UIBezierPath bezierPath];
            [verticalBarInAddButtonPath moveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 41, CGRectGetMinY(bottomRightButtonsFrame) + 21)];
            [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 41, CGRectGetMinY(bottomRightButtonsFrame) + 37.57)];
            [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 41, CGRectGetMinY(bottomRightButtonsFrame) + 54)];
            [verticalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 41, CGRectGetMinY(bottomRightButtonsFrame) + 54)];
            [whiteCircleButtonFill setFill];
            [verticalBarInAddButtonPath fill];
            [blackCircleButtonOutline setStroke];
            verticalBarInAddButtonPath.lineWidth = 1.5;
            [verticalBarInAddButtonPath stroke];
            
            
            //// Horizontal Bar in Add Button Drawing
            UIBezierPath* horizontalBarInAddButtonPath = [UIBezierPath bezierPath];
            [horizontalBarInAddButtonPath moveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 24.5, CGRectGetMinY(bottomRightButtonsFrame) + 37.5)];
            [horizontalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 41.03, CGRectGetMinY(bottomRightButtonsFrame) + 37.5)];
            [horizontalBarInAddButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 57.5, CGRectGetMinY(bottomRightButtonsFrame) + 37.5)];
            [strokeColor setStroke];
            horizontalBarInAddButtonPath.lineWidth = 1.5;
            [horizontalBarInAddButtonPath stroke];
        }
    }
}

@end
