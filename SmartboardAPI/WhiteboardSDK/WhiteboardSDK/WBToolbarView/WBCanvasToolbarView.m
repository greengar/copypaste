//
//  WBCanvasToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasToolbarView.h"
#import "WBCanvasButton.h"

@implementation WBCanvasToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // for debugging
        //self.backgroundColor = [UIColor greenColor];
        
        self.opaque = NO; // necessary due to rounded corners
        
        float canvasButtonWidth = 79;
        WBCanvasButton *button = [[WBCanvasButton alloc] initWithFrame:CGRectMake(self.frame.size.width-canvasButtonWidth, 0, canvasButtonWidth, 100)];
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:button];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float colorCircleOffset = 40;
    
    
    
    
    //// Color Declarations
//    UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
//    UIColor* currentBrushColor = [UIColor colorWithRed: 0.831 green: 0.137 blue: 0.329 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* lightGrayOutlineColor = [UIColor colorWithRed: 0.757 green: 0.757 blue: 0.757 alpha: 1];
    UIColor* yellowFillColor = [UIColor colorWithRed: 0.847 green: 0.796 blue: 0.188 alpha: 1];
    
    
    
    //// Frames
    CGRect bottomToolbarFrame = self.bounds; //CGRectMake(285, 669, 444, 74);
    
    
    
    //// Recent Tray Drawing
    UIBezierPath* recentTrayPath = [UIBezierPath bezierPath];
    [recentTrayPath moveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 363.5, CGRectGetMinY(bottomToolbarFrame) + 73.5)];
    [recentTrayPath addLineToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 6.5, CGRectGetMinY(bottomToolbarFrame) + 73.5)];
    [recentTrayPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.5, CGRectGetMinY(bottomToolbarFrame) + 67.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 6.5, CGRectGetMinY(bottomToolbarFrame) + 73.5) controlPoint2: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.56, CGRectGetMinY(bottomToolbarFrame) + 73.38)];
    [recentTrayPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.5, CGRectGetMinY(bottomToolbarFrame) + 6.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.44, CGRectGetMinY(bottomToolbarFrame) + 61.62) controlPoint2: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.5, CGRectGetMinY(bottomToolbarFrame) + 6.5)];
    [recentTrayPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 6.5, CGRectGetMinY(bottomToolbarFrame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.5, CGRectGetMinY(bottomToolbarFrame) + 6.5) controlPoint2: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 0.78, CGRectGetMinY(bottomToolbarFrame) + 0.5)];
    [recentTrayPath addCurveToPoint: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 363.5, CGRectGetMinY(bottomToolbarFrame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 12.22, CGRectGetMinY(bottomToolbarFrame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(bottomToolbarFrame) + 363.5, CGRectGetMinY(bottomToolbarFrame) + 0.5)];
    [color setFill];
    [recentTrayPath fill];
    [lightGrayOutlineColor setStroke];
    recentTrayPath.lineWidth = 1;
    [recentTrayPath stroke];
    
    
    //// Yellow Recent Brush Circle Drawing
    UIBezierPath* yellowRecentBrushCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(bottomToolbarFrame) + 310.5 - colorCircleOffset, CGRectGetMinY(bottomToolbarFrame) + 17.5, 35, 35)];
    [yellowFillColor setFill];
    [yellowRecentBrushCirclePath fill];
    [strokeColor setStroke];
    yellowRecentBrushCirclePath.lineWidth = 2;
    [yellowRecentBrushCirclePath stroke];
}

@end
