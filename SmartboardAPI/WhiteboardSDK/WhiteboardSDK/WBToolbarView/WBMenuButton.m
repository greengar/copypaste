//
//  WBMenuButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/19/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBMenuButton.h"

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
    UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* blackCircleButtonOutline = [UIColor colorWithRed: 0.157 green: 0.157 blue: 0.157 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    // Use bitwise & operator to see whether the state is highlighted or selected
    if (self.state & UIControlStateHighlighted || self.state & UIControlStateSelected)
    {
        // ordering here is important
        UIColor* blackCircleButtonOutlineTemp = [blackCircleButtonOutline copy];
        blackCircleButtonOutline = selectedButtonOutlineWhite;
        strokeColor = selectedButtonOutlineWhite;
        selectedButtonOutlineWhite = blackCircleButtonOutlineTemp;
        
    }
    
    //// Frames
    CGRect menuButtonFrame = self.bounds; //CGRectMake(19, 18, 81, 74);
    
    
    //// Menu Button Group
    {
        //// Menu Button Circle Drawing
        UIBezierPath* menuButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(menuButtonFrame) + 11.5, CGRectGetMinY(menuButtonFrame) + 8.5, 56, 56)];
        [selectedButtonOutlineWhite setFill];
        [menuButtonCirclePath fill];
        [strokeColor setStroke];
        menuButtonCirclePath.lineWidth = 1.5;
        [menuButtonCirclePath stroke];
        
        
        //// Menu Top Line Drawing
        UIBezierPath* menuTopLinePath = [UIBezierPath bezierPath];
        [menuTopLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 26.5)];
        [menuTopLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 26.5)];
        menuTopLinePath.lineCapStyle = kCGLineCapRound;
        
        [blackCircleButtonOutline setStroke];
        menuTopLinePath.lineWidth = 3;
        [menuTopLinePath stroke];
        
        
        //// Menu Middle Line Drawing
        UIBezierPath* menuMiddleLinePath = [UIBezierPath bezierPath];
        [menuMiddleLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 37.5)];
        [menuMiddleLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 37.5)];
        menuMiddleLinePath.lineCapStyle = kCGLineCapRound;
        
        [blackCircleButtonOutline setStroke];
        menuMiddleLinePath.lineWidth = 3;
        [menuMiddleLinePath stroke];
        
        
        //// Menu Button Line Drawing
        UIBezierPath* menuButtonLinePath = [UIBezierPath bezierPath];
        [menuButtonLinePath moveToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 23.5, CGRectGetMinY(menuButtonFrame) + 47.5)];
        [menuButtonLinePath addLineToPoint: CGPointMake(CGRectGetMinX(menuButtonFrame) + 54.5, CGRectGetMinY(menuButtonFrame) + 47.5)];
        menuButtonLinePath.lineCapStyle = kCGLineCapRound;
        
        [blackCircleButtonOutline setStroke];
        menuButtonLinePath.lineWidth = 3;
        [menuButtonLinePath stroke];
    }
    
    

}

@end
