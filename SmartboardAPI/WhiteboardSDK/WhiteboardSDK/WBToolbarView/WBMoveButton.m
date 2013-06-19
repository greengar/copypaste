//
//  WBMoveButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBMoveButton.h"

@implementation WBMoveButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* blackCircleButtonOutline = [UIColor colorWithRed: 0.157 green: 0.157 blue: 0.157 alpha: 1];
    UIColor* whiteCircleButtonFill = [UIColor colorWithRed: 0.996 green: 0.996 blue: 0.996 alpha: 1];
    
    // Use bitwise & operator to see whether the state is highlighted or selected
    if (self.state & UIControlStateHighlighted || self.state & UIControlStateSelected)
    {
        // ordering here is important
        UIColor* selectedButtonOutlineWhiteTemp = [whiteCircleButtonFill copy];
        selectedButtonOutlineWhite = blackCircleButtonOutline;
        whiteCircleButtonFill =  blackCircleButtonOutline;
        blackCircleButtonOutline = selectedButtonOutlineWhiteTemp;
        
    }
    
    //// Frames
    CGRect moveButtonGroupFrame = self.bounds; //CGRectMake(808, 669, 76, 73);
    
    
    //// Bottom Right Toolbar Tray
    {
        //// Move Button Group
        {
            //// Move Button Circle Drawing
            UIBezierPath* moveButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(moveButtonGroupFrame) + 9, CGRectGetMinY(moveButtonGroupFrame) + 8, 56, 56)];
            [whiteCircleButtonFill setFill];
            [moveButtonCirclePath fill];
            [blackCircleButtonOutline setStroke];
            moveButtonCirclePath.lineWidth = 2;
            [moveButtonCirclePath stroke];
            
            
            //// Up Arrow in Move Button Drawing
            UIBezierPath* upArrowInMoveButtonPath = [UIBezierPath bezierPath];
            [upArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30, CGRectGetMinY(moveButtonGroupFrame) + 27)];
            [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 44, CGRectGetMinY(moveButtonGroupFrame) + 27)];
            [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 37, CGRectGetMinY(moveButtonGroupFrame) + 20)];
            [upArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30, CGRectGetMinY(moveButtonGroupFrame) + 27)];
            [upArrowInMoveButtonPath closePath];
            [whiteCircleButtonFill setFill];
            [upArrowInMoveButtonPath fill];
            [blackCircleButtonOutline setStroke];
            upArrowInMoveButtonPath.lineWidth = 1.5;
            [upArrowInMoveButtonPath stroke];
            
            
            //// Down Arrow in Move Button Drawing
            UIBezierPath* downArrowInMoveButtonPath = [UIBezierPath bezierPath];
            [downArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30, CGRectGetMinY(moveButtonGroupFrame) + 47)];
            [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 44, CGRectGetMinY(moveButtonGroupFrame) + 47)];
            [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 37, CGRectGetMinY(moveButtonGroupFrame) + 54)];
            [downArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 30, CGRectGetMinY(moveButtonGroupFrame) + 47)];
            [downArrowInMoveButtonPath closePath];
            [whiteCircleButtonFill setFill];
            [downArrowInMoveButtonPath fill];
            [blackCircleButtonOutline setStroke];
            downArrowInMoveButtonPath.lineWidth = 1.5;
            [downArrowInMoveButtonPath stroke];
            
            
            //// Left Arrow in Move Button Drawing
            UIBezierPath* leftArrowInMoveButtonPath = [UIBezierPath bezierPath];
            [leftArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 27, CGRectGetMinY(moveButtonGroupFrame) + 30)];
            [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 27, CGRectGetMinY(moveButtonGroupFrame) + 44)];
            [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 20, CGRectGetMinY(moveButtonGroupFrame) + 36)];
            [leftArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 27, CGRectGetMinY(moveButtonGroupFrame) + 30)];
            [leftArrowInMoveButtonPath closePath];
            [whiteCircleButtonFill setFill];
            [leftArrowInMoveButtonPath fill];
            [blackCircleButtonOutline setStroke];
            leftArrowInMoveButtonPath.lineWidth = 1.5;
            [leftArrowInMoveButtonPath stroke];
            
            
            //// Right Arrow in Move Button Drawing
            UIBezierPath* rightArrowInMoveButtonPath = [UIBezierPath bezierPath];
            [rightArrowInMoveButtonPath moveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 48, CGRectGetMinY(moveButtonGroupFrame) + 30)];
            [rightArrowInMoveButtonPath addLineToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 48, CGRectGetMinY(moveButtonGroupFrame) + 43)];
            [rightArrowInMoveButtonPath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 54, CGRectGetMinY(moveButtonGroupFrame) + 37) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 48, CGRectGetMinY(moveButtonGroupFrame) + 43) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 53.71, CGRectGetMinY(moveButtonGroupFrame) + 37.29)];
            [rightArrowInMoveButtonPath addCurveToPoint: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 48, CGRectGetMinY(moveButtonGroupFrame) + 30) controlPoint1: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 54.29, CGRectGetMinY(moveButtonGroupFrame) + 36.71) controlPoint2: CGPointMake(CGRectGetMinX(moveButtonGroupFrame) + 48, CGRectGetMinY(moveButtonGroupFrame) + 30)];
            [rightArrowInMoveButtonPath closePath];
            [whiteCircleButtonFill setFill];
            [rightArrowInMoveButtonPath fill];
            [blackCircleButtonOutline setStroke];
            rightArrowInMoveButtonPath.lineWidth = 1.5;
            [rightArrowInMoveButtonPath stroke];
            
            
            //// Small Circle in Move Button Drawing
            UIBezierPath* smallCircleInMoveButtonPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(moveButtonGroupFrame) + 33.5, CGRectGetMinY(moveButtonGroupFrame) + 33.5, 7, 7)];
            [selectedButtonOutlineWhite setFill];
            [smallCircleInMoveButtonPath fill];
            [blackCircleButtonOutline setStroke];
            smallCircleInMoveButtonPath.lineWidth = 1.5;
            [smallCircleInMoveButtonPath stroke];
        }
    }
    
    

}

@end
