//
//  GSColorCircle.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 4/15/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "GSColorCircle.h"
#import "SettingManager.h"

@implementation GSColorCircle
@synthesize circleColor = _circleColor;
@synthesize circleOpacity = _circleOpacity;
@synthesize circlePointSize = _circlePointSize;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.circleOpacity = 1.0f;
        self.circlePointSize = kDefaultPointSize;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)nColor andOpacity:(float)newOpacity andPointSize:(float)newPointSize {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.circleColor = nColor;
        self.circleOpacity = newOpacity;
        self.circlePointSize = newPointSize;
    }
    return self;
}

- (CGColorRef)CGColorFromUIColor:(UIColor *)drawingColor opacity:(float)drawingOpacity pointSize:(float)drawingPointSize {
	const CGFloat *colorComponents = CGColorGetComponents(drawingColor.CGColor);
	float previewComponents[4];
	previewComponents[0] = colorComponents[0];
	previewComponents[1] = colorComponents[1];
	previewComponents[2] = colorComponents[2];
	previewComponents[3] = drawingOpacity; //1.0 - powf(1.0 - drawingOpacity, drawingPointSize * 2.0 / 1.0);
	CGColorRef newColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), previewComponents);
	return newColor;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	
	CGContextSetLineWidth(context, 0.0f);
	CGFloat diameter = 12 + (self.circlePointSize*(21-12))/((IS_IPAD)?18.0f:32.0f);
	
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor);
	CGRect currentRect = CGRectMake(self.frame.size.width/2-diameter/2+1, self.frame.size.height/2-diameter/2+1, diameter, diameter);
	CGContextAddEllipseInRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFill);
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	currentRect = CGRectMake(self.frame.size.width/2-diameter/2, self.frame.size.height/2-diameter/2, diameter, diameter);
	CGContextAddEllipseInRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFill);
	
	CGColorRef colorRef = [self CGColorFromUIColor:self.circleColor opacity:self.circleOpacity pointSize:self.circlePointSize];
	CGContextSetFillColorWithColor(context, colorRef);
	currentRect = CGRectMake(self.frame.size.width/2-diameter/2+1, self.frame.size.height/2-diameter/2+1, diameter-2, diameter-2);
	CGContextAddEllipseInRect(context, currentRect);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	CGColorRelease(colorRef);
}

@end
