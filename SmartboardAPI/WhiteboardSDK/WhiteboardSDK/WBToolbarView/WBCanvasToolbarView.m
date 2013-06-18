//
//  WBCanvasToolbarView.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasToolbarView.h"
#import "WBCanvasButton.h"
#import "SettingManager.h"

#define kCanvasButtonTag 777

@interface WBCanvasToolbarView()
@property (nonatomic, strong) WBCanvasButton *canvasButton;
@end

@implementation WBCanvasToolbarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO; // necessary due to rounded corners
        
        self.canvasButton = [[WBCanvasButton alloc] initWithFrame:CGRectMake(self.frame.size.width-kCanvasButtonWidth,
                                                                             0, kCanvasButtonWidth, frame.size.height)];
        self.canvasButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.canvasButton.tag = kCanvasButtonTag;
        [self.canvasButton addTarget:self action:@selector(showColorSpectrum:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.canvasButton];
    }
    return self;
}

- (void)showColorSpectrum:(WBCanvasButton *)button {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showColorSpectrum:)]) {
        [self.delegate showColorSpectrum:!button.isSelected];
    }
    [button setSelected:!button.isSelected];
}

- (void)updateColor:(UIColor *)color {
    [self.canvasButton setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)updateAlpha:(float)alpha {
    [self.canvasButton setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)updatePointSize:(float)pointSize {
    [self.canvasButton setNeedsDisplay];
    [self setNeedsDisplay];
}

- (void)monitorClosed {
    [self.canvasButton setSelected:NO];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    float barWidth = self.frame.size.width-kCanvasButtonWidth;
    float barHeight = self.frame.size.height;
    // Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* lightGrayOutlineColor = [UIColor colorWithRed: 0.757 green: 0.757 blue: 0.757 alpha: 1];

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
    
    for (int i = 0; i < 6; i++) {
        float colorSize = [[SettingManager sharedManager] getColorTabAtIndex:i].pointSize*1.5;
        UIColor *color = [[SettingManager sharedManager] getColorTabAtIndex:i].tabColor;
        float red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        alpha = [[SettingManager sharedManager] getColorTabAtIndex:i].opacity;
        UIColor *alphaColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        UIBezierPath* historyColorPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(barWidth-barWidth*(i+1)/6+(barWidth/6-colorSize)/2,
                                                                                           (barHeight-colorSize)/2,
                                                                                           colorSize,
                                                                                           colorSize)];
        [alphaColor setFill];
        [historyColorPath fill];
        [strokeColor setStroke];
        historyColorPath.lineWidth = 2;
        [historyColorPath stroke];
    }
}

@end
