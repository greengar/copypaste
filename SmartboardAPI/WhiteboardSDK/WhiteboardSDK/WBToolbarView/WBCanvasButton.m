//
//  WBCanvasButton.m
//  Whiteboard7
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasButton.h"
#import "SettingManager.h"

@implementation WBCanvasButton
@synthesize eraserEnabled = _eraserEnabled;

static inline int PerceivedBrightness(float red, float green, float blue, float alpha)
{
    alpha = 1-alpha;
    
    float bgred = 1, bggreen = 1, bgblue = 1;
    
    red   = ((1-alpha)*red)  +(alpha*bgred);
    green = ((1-alpha)*green)+(alpha*bggreen);
    blue  = ((1-alpha)*blue)  +(alpha*bgblue);
    
    // convert values from range [0-1] to range [0-255]
    
    red *= 255.0f;
    green *= 255.0f;
    blue *= 255.0f;
    
//    alpha = 1 - alpha;
//    
//    //float bgred = 1, bggreen = 1, bgblue = 1;
//    float bgred = 255, bggreen = 255, bgblue = 255;
//    
//    //blue = 255.0f * (alpha * blue + alpha * bgblue);
//    
//    red = (alpha * (red / 255) + alpha * (bgred / 255)) * 255;
//    blue = (alpha * (blue / 255) + alpha * (bgblue / 255)) * 255;
//    green = (alpha * (green / 255) + alpha * (bggreen / 255)) * 255;
    
    float brightness = sqrtf(red * red * .241 +
                             green * green * .691 +
                             blue * blue * .068);
    
    return brightness;
    // brightness > 130 ? black : white
}

- (void)drawRect:(CGRect)rect {
    if (self.eraserEnabled) {
        //// Color Declarations
        UIColor* blackCircleButtonOutline = [UIColor colorWithRed: 0.157 green: 0.157 blue: 0.157 alpha: 1];
        UIColor* whiteCircleButtonFill = [UIColor colorWithRed: 0.996 green: 0.996 blue: 0.996 alpha: 1];
        UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1]; //black
        UIColor* eraserWhiteColor = [UIColor colorWithRed: 0.988 green: 0.988 blue: 0.988 alpha: 1];
        UIColor* eraserBlackColor = [UIColor colorWithRed: 0.145 green: 0.145 blue: 0.145 alpha: 1];
                
        //// Frames
        CGRect frame = self.bounds; //CGRectMake(754, 489, 61, 61);
        
        
        //// Eraser Button Group
        {
            //// Eraser Button Circle Drawing
            UIBezierPath* eraserButtonCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 9.5, 56, 56)];
            [whiteCircleButtonFill setFill];
            [eraserButtonCirclePath fill];
            [blackCircleButtonOutline setStroke];
            eraserButtonCirclePath.lineWidth = 1;
            [eraserButtonCirclePath stroke];
            
            //// Eraser Outline Bezier Drawing
            UIBezierPath* eraserOutlineBezierPath = [UIBezierPath bezierPath];
            [eraserOutlineBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 40.5)];
            [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 46.5, CGRectGetMinY(frame) + 23.5)];
            [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 56, CGRectGetMinY(frame) + 33)];
            [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 41.5, CGRectGetMinY(frame) + 47.5)];
            [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 47.5)];
            [eraserOutlineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30.5, CGRectGetMinY(frame) + 40.5)];
            [eraserOutlineBezierPath closePath];
            [eraserWhiteColor setFill];
            [eraserOutlineBezierPath fill];
            [strokeColor setStroke];
            eraserOutlineBezierPath.lineWidth = 1.5;
            [eraserOutlineBezierPath stroke];
            
            
            //// Eraser Black Area Bezier Drawing
            UIBezierPath* eraserBlackAreaBezierPath = [UIBezierPath bezierPath];
            [eraserBlackAreaBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 38, CGRectGetMinY(frame) + 33)];
            [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 47.5, CGRectGetMinY(frame) + 42.5)];
            [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 56.5, CGRectGetMinY(frame) + 33.5)];
            [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 46.5, CGRectGetMinY(frame) + 23.5)];
            [eraserBlackAreaBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 38, CGRectGetMinY(frame) + 33)];
            [eraserBlackAreaBezierPath closePath];
            [eraserBlackColor setFill];
            [eraserBlackAreaBezierPath fill];
            
            
            //// Eraser Line Bezier Drawing
            UIBezierPath* eraserLineBezierPath = [UIBezierPath bezierPath];
            [eraserLineBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.5, CGRectGetMinY(frame) + 51)];
            [eraserLineBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 51)];
            [eraserBlackColor setFill];
            [eraserLineBezierPath fill];
            [strokeColor setStroke];
            eraserLineBezierPath.lineWidth = 2;
            [eraserLineBezierPath stroke];
            
            //// Top Arrow Tip Drawing
            UIBezierPath* topArrowTipPath = [UIBezierPath bezierPath];
            [topArrowTipPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 5.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 44.5, CGRectGetMinY(frame) + 5.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 40.5, CGRectGetMinY(frame) + 2.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 36.5, CGRectGetMinY(frame) + 5.5)];
            [topArrowTipPath closePath];
            [eraserBlackColor setFill];
            [topArrowTipPath fill];
        }

    } else {
        // Color Declarations
        UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        
        UIColor* tabColor = [[SettingManager sharedManager] getCurrentColorTab].tabColor;
        float red, green, blue, alpha;
        [tabColor getRed:&red green:&green blue:&blue alpha:&alpha];
        alpha = [[SettingManager sharedManager] getCurrentColorTab].opacity;
        UIColor* currentBrushColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        if (PerceivedBrightness(red, green, blue, alpha) > 130)
        {
            selectedButtonOutlineWhite = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        
        if (self.state == UIControlStateHighlighted)
        {
            CGFloat currentBrushColorRGBA[4];
            [currentBrushColor getRed: &currentBrushColorRGBA[0] green: &currentBrushColorRGBA[1] blue: &currentBrushColorRGBA[2] alpha: &currentBrushColorRGBA[3]];
            
            currentBrushColor = [UIColor colorWithRed: (currentBrushColorRGBA[0] * 0.5 + 0.5) green: (currentBrushColorRGBA[1] * 0.5 + 0.5) blue: (currentBrushColorRGBA[2] * 0.5 + 0.5) alpha: (currentBrushColorRGBA[3] * 0.5 + 0.5)];
            
        }
        
        //// Subframes
        CGRect canvasButtonFrame = self.bounds;
        
        
        //// Group
        {
            //// Selected Brush Square Background Drawing
            UIBezierPath* selectedBrushSquareBackgroundPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(canvasButtonFrame) + 0.5, CGRectGetMinY(canvasButtonFrame) + 0.5, 79, 74)];
            [currentBrushColor setFill];
            [selectedBrushSquareBackgroundPath fill];
            
            
            //// Selected Brush Circle Button Drawing
            UIBezierPath* selectedBrushCircleButtonPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(canvasButtonFrame) + 12.5, CGRectGetMinY(canvasButtonFrame) + 9.5, 56, 56)];
            [selectedButtonOutlineWhite setStroke];
            selectedBrushCircleButtonPath.lineWidth = 1;
            [selectedBrushCircleButtonPath stroke];
            
            
            //// Pencil Tip Drawing
            UIBezierPath* pencilTipPath = [UIBezierPath bezierPath];
            [pencilTipPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 28, CGRectGetMinY(canvasButtonFrame) + 45)];
            [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 25, CGRectGetMinY(canvasButtonFrame) + 54)];
            [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 34, CGRectGetMinY(canvasButtonFrame) + 51)];
            [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 28, CGRectGetMinY(canvasButtonFrame) + 45)];
            [pencilTipPath closePath];
            [selectedButtonOutlineWhite setFill];
            [pencilTipPath fill];
            
            
            //// Pencil Body Drawing
            UIBezierPath* pencilBodyPath = [UIBezierPath bezierPath];
            [pencilBodyPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 30, CGRectGetMinY(canvasButtonFrame) + 44)];
            [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 35.5, CGRectGetMinY(canvasButtonFrame) + 49.5)];
            [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 52, CGRectGetMinY(canvasButtonFrame) + 33)];
            [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 46, CGRectGetMinY(canvasButtonFrame) + 27)];
            [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 30, CGRectGetMinY(canvasButtonFrame) + 44)];
            [pencilBodyPath closePath];
            [selectedButtonOutlineWhite setFill];
            [pencilBodyPath fill];
            
            
            //// Pencil Eraser Drawing
            UIBezierPath* pencilEraserPath = [UIBezierPath bezierPath];
            [pencilEraserPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 47.5, CGRectGetMinY(canvasButtonFrame) + 25.5)];
            [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 51.5, CGRectGetMinY(canvasButtonFrame) + 21.5)];
            [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 57.5, CGRectGetMinY(canvasButtonFrame) + 27.5)];
            [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 53.5, CGRectGetMinY(canvasButtonFrame) + 31.5)];
            [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 47.5, CGRectGetMinY(canvasButtonFrame) + 25.5)];
            [pencilEraserPath closePath];
            [selectedButtonOutlineWhite setFill];
            [pencilEraserPath fill];
            
            
            //// Top Arrow Tip Drawing
            UIBezierPath* topArrowTipPath = [UIBezierPath bezierPath];
            [topArrowTipPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 36.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 44.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 40.5, CGRectGetMinY(canvasButtonFrame) + 2.5)];
            [topArrowTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 36.5, CGRectGetMinY(canvasButtonFrame) + 5.5)];
            [topArrowTipPath closePath];
            [selectedButtonOutlineWhite setFill];
            [topArrowTipPath fill];
            
            
        }
    }
}

@end
