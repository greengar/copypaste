//
//  WBBottomRightToolbarView.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBBottomRightToolbarView.h"

@implementation WBBottomRightToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //// Color Declarations
    UIColor* translucentWhiteBackground = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* lightGrayOutlineColor = [UIColor colorWithRed: 0.757 green: 0.757 blue: 0.757 alpha: 1];
    
    //// Frames
    CGRect bottomRightButtonsFrame = self.bounds; //CGRectMake(729, 668, 156, 75);
    
    //// Subframes
    CGRect bottomToolbarFrame = CGRectMake(CGRectGetMinX(bottomRightButtonsFrame) - 444, CGRectGetMinY(bottomRightButtonsFrame), 444, 74);
    
    
    //// Bottom Right Toolbar Tray
    {
        //// Bottom Right Tray Bezier Drawing
        UIBezierPath* bottomRightTrayBezierPath = [UIBezierPath bezierPath];
        [bottomRightTrayBezierPath moveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 443.5, CGRectGetMinY(bottomToolbarFrame) + 0.5)];
        [bottomRightTrayBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 150.5, CGRectGetMinY(bottomRightButtonsFrame) + 0.5)];
        [bottomRightTrayBezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 5.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 150.5, CGRectGetMinY(bottomRightButtonsFrame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 0.6)];
        [bottomRightTrayBezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 69.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 10.4) controlPoint2: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 69.5)];
        [bottomRightTrayBezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 150.56, CGRectGetMinY(bottomRightButtonsFrame) + 74.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.5, CGRectGetMinY(bottomRightButtonsFrame) + 69.5) controlPoint2: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 155.39, CGRectGetMinY(bottomRightButtonsFrame) + 74.43)];
        [bottomRightTrayBezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) - 0.5, CGRectGetMinY(bottomRightButtonsFrame) + 74.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) + 145.74, CGRectGetMinY(bottomRightButtonsFrame) + 74.57) controlPoint2: CGPointMake(CGRectGetMinX(bottomRightButtonsFrame) - 0.5, CGRectGetMinY(bottomRightButtonsFrame) + 74.5)];
        [translucentWhiteBackground setFill];
        [bottomRightTrayBezierPath fill];
        [lightGrayOutlineColor setStroke];
        bottomRightTrayBezierPath.lineWidth = 1;
        [bottomRightTrayBezierPath stroke];
    }
    
    

}

@end
