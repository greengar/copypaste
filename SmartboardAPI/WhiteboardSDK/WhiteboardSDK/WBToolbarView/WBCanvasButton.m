//
//  WBCanvasButton.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/12/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBCanvasButton.h"
#import "SettingManager.h"

@interface WBCanvasButton ()

@property (nonatomic, copy) NSString *fontName;

@end

@implementation WBCanvasButton

static inline int PerceivedBrightness(float red, float green, float blue, float alpha)
{
    alpha = 1-alpha;
    
    float bgred = 1, bggreen = 1, bgblue = 1;
    
    red   = ((1-alpha)*red)  +(alpha*bgred);
    green = ((1-alpha)*green)+(alpha*bggreen);
    blue  = ((1-alpha)*blue) +(alpha*bgblue);
    
    // convert values from range [0-1] to range [0-255]
    red *= 255.0f;
    green *= 255.0f;
    blue *= 255.0f;
    
    float brightness = sqrtf(red * red * .241 +
                             green * green * .691 +
                             blue * blue * .068);
    
    // brightness > 130 ? black : white
    return brightness;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.fontName = kDefaultFontName;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateFont:) name:@"didUpdateFont" object:nil];
    }
    return self;
}

- (void)didUpdateFont:(NSNotification *)n
{
    NSDictionary *d = [n userInfo];
    self.fontName = d[@"fontName"];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.mode == kEraserMode) {
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

    } else if (self.mode == kTextMode) {
        // Text mode
        
        //// Color Declarations
        UIColor* selectedButtonOutlineWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        
        ///////////////////////////////////
        // Copied from Canvas mode below //
        
        UIColor* tabColor = [[SettingManager sharedManager] getCurrentColorTab].tabColor;
        float red, green, blue, alpha;
        [tabColor getRed:&red green:&green blue:&blue alpha:&alpha];
        alpha = [[SettingManager sharedManager] getCurrentColorTab].opacity;
        UIColor* currentBrushColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        if (PerceivedBrightness(red, green, blue, alpha) > 130)
        {
            selectedButtonOutlineWhite = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
        
        if (self.state & UIControlStateHighlighted)
        {
            CGFloat currentBrushColorRGBA[4];
            [currentBrushColor getRed: &currentBrushColorRGBA[0] green: &currentBrushColorRGBA[1] blue: &currentBrushColorRGBA[2] alpha: &currentBrushColorRGBA[3]];
            
            currentBrushColor = [UIColor colorWithRed: (currentBrushColorRGBA[0] * 0.5 + 0.5) green: (currentBrushColorRGBA[1] * 0.5 + 0.5) blue: (currentBrushColorRGBA[2] * 0.5 + 0.5) alpha: (currentBrushColorRGBA[3] * 0.5 + 0.5)];
            
        }
        
        // Copied from Canvas mode above //
        ///////////////////////////////////
        
        //// Frames
        CGRect canvasButtonFrameText = self.bounds; //CGRectMake(648, 669, 81, 74);
        
        
        //// Abstracted Attributes
        UIFont* abcTextFont = [UIFont fontWithName: self.fontName size: 18.5];
        
        
        //// Canvas Toolbar Group
        {
            //// Canvas Button Group: Text
            {
                //// Background Rectangle: Text Drawing
                UIBezierPath* backgroundRectangleTextPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(canvasButtonFrameText), CGRectGetMinY(canvasButtonFrameText), 81, 74)];
                [currentBrushColor setFill];
                [backgroundRectangleTextPath fill];
                
                
                //// Selected Brush Circle: Text Drawing
                UIBezierPath* selectedBrushCircleTextPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(canvasButtonFrameText) + 12.5, CGRectGetMinY(canvasButtonFrameText) + 8.5, 56, 56)];
                [selectedButtonOutlineWhite setStroke];
                selectedBrushCircleTextPath.lineWidth = 1.5;
                [selectedBrushCircleTextPath stroke];
                
                
                //// Top Arrow Tip: Text Drawing
                UIBezierPath* topArrowTipTextPath = [UIBezierPath bezierPath];
                [topArrowTipTextPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrameText) + 36.5, CGRectGetMinY(canvasButtonFrameText) + 5.5)];
                [topArrowTipTextPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrameText) + 44.5, CGRectGetMinY(canvasButtonFrameText) + 5.5)];
                [topArrowTipTextPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrameText) + 40.5, CGRectGetMinY(canvasButtonFrameText) + 2.5)];
                [topArrowTipTextPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrameText) + 36.5, CGRectGetMinY(canvasButtonFrameText) + 5.5)];
                [topArrowTipTextPath closePath];
                [selectedButtonOutlineWhite setFill];
                [topArrowTipTextPath fill];
                
                
                //// Abc Text Drawing
                ////////////////////////////////////////////////////////
                // This section is custom (not copied from PaintCode) //
                ////////////////////////////////////////////////////////
                
                CGRect abcTextRect = CGRectMake(CGRectGetMinX(canvasButtonFrameText) + 12.5, CGRectGetMinY(canvasButtonFrameText) + 8.5, 56, 56);
                
                NSString *text = @"Abc";
                CGFloat fontHeight = [text sizeWithFont:abcTextFont].height;
                // this seems to give the same result:
                //CGFloat fontHeight = [abcTextFont lineHeight];
                CGFloat yOffset = (abcTextRect.size.height - fontHeight) / 2.0;
                abcTextRect = CGRectMake(abcTextRect.origin.x, abcTextRect.origin.y + yOffset, abcTextRect.size.width, fontHeight);
                
                [selectedButtonOutlineWhite setFill];
                [text drawInRect: abcTextRect withFont: abcTextFont lineBreakMode: UILineBreakModeClip alignment: NSTextAlignmentCenter];
            }
        }
        
    } else {
        // Canvas (drawing) mode
        
        //// Color Declarations
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
        
        if (self.state & UIControlStateHighlighted)
        {
            CGFloat currentBrushColorRGBA[4];
            [currentBrushColor getRed: &currentBrushColorRGBA[0] green: &currentBrushColorRGBA[1] blue: &currentBrushColorRGBA[2] alpha: &currentBrushColorRGBA[3]];
            
            currentBrushColor = [UIColor colorWithRed: (currentBrushColorRGBA[0] * 0.5 + 0.5) green: (currentBrushColorRGBA[1] * 0.5 + 0.5) blue: (currentBrushColorRGBA[2] * 0.5 + 0.5) alpha: (currentBrushColorRGBA[3] * 0.5 + 0.5)];
            
        }
        
        //// Frames
        CGRect canvasButtonFrame = self.bounds; //CGRectMake(648, 669, 81, 74);
        
        
        //// Canvas Toolbar Group
        {
            //// Canvas Button Group
            {
                //// Selected Brush Square Background Drawing
                UIBezierPath* selectedBrushSquareBackgroundPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(canvasButtonFrame), CGRectGetMinY(canvasButtonFrame), 81, 74)];
                [currentBrushColor setFill];
                [selectedBrushSquareBackgroundPath fill];
                
                
                //// Selected Brush Circle Drawing
                UIBezierPath* selectedBrushCirclePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(canvasButtonFrame) + 12.5, CGRectGetMinY(canvasButtonFrame) + 8.5, 56, 56)];
                [selectedButtonOutlineWhite setStroke];
                selectedBrushCirclePath.lineWidth = 1.5;
                [selectedBrushCirclePath stroke];
                
                
                //// Pencil Tip Drawing
                UIBezierPath* pencilTipPath = [UIBezierPath bezierPath];
                [pencilTipPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 29.5, CGRectGetMinY(canvasButtonFrame) + 43.5)];
                [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 26.5, CGRectGetMinY(canvasButtonFrame) + 52)];
                [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 35, CGRectGetMinY(canvasButtonFrame) + 49)];
                [pencilTipPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 29.5, CGRectGetMinY(canvasButtonFrame) + 43.5)];
                [pencilTipPath closePath];
                [selectedButtonOutlineWhite setFill];
                [pencilTipPath fill];
                
                
                //// Pencil Body Drawing
                UIBezierPath* pencilBodyPath = [UIBezierPath bezierPath];
                [pencilBodyPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 31, CGRectGetMinY(canvasButtonFrame) + 42)];
                [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 36.5, CGRectGetMinY(canvasButtonFrame) + 47.5)];
                [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 53, CGRectGetMinY(canvasButtonFrame) + 31)];
                [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 47, CGRectGetMinY(canvasButtonFrame) + 25)];
                [pencilBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 31, CGRectGetMinY(canvasButtonFrame) + 42)];
                [pencilBodyPath closePath];
                [selectedButtonOutlineWhite setFill];
                [pencilBodyPath fill];
                
                
                //// Pencil Eraser Drawing
                UIBezierPath* pencilEraserPath = [UIBezierPath bezierPath];
                [pencilEraserPath moveToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 48.5, CGRectGetMinY(canvasButtonFrame) + 23.5)];
                [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 52.5, CGRectGetMinY(canvasButtonFrame) + 19.5)];
                [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 58.5, CGRectGetMinY(canvasButtonFrame) + 25.5)];
                [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 54.5, CGRectGetMinY(canvasButtonFrame) + 29.5)];
                [pencilEraserPath addLineToPoint: CGPointMake(CGRectGetMinX(canvasButtonFrame) + 48.5, CGRectGetMinY(canvasButtonFrame) + 23.5)];
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
