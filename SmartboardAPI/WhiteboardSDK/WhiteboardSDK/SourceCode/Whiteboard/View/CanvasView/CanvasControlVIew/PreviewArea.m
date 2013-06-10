//
//  PreviewArea.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 1/7/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//

#import "PreviewArea.h"
#import "SettingManager.h"
#import "WBUtils.h"

@implementation PreviewArea

- (void) colorChanged:(CGFloat *)color isSelf:(BOOL)is {
    if(is) {
        
    } else {
        
    }
}

- (void) pointSizeChanged:(CGFloat)pointSize isSelf:(BOOL)is {
    if(is) {
        
    } else {
        
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
    }
    return self;
}

- (CGColorRef)CGColorFromUIColor:(UIColor *)drawingColor opacity:(float)drawingOpacity {
	const CGFloat *colorComponents = CGColorGetComponents(drawingColor.CGColor);
	float previewComponents[4];
	previewComponents[0] = colorComponents[0];
	previewComponents[1] = colorComponents[1];
	previewComponents[2] = colorComponents[2];
	previewComponents[3] = drawingOpacity;
    
	CGColorRef newColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), previewComponents);
	return newColor;
}

- (void)drawRect:(CGRect)rect {
	
		
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.0);
    CGFloat previewOffset = kMaxPointSize - [[SettingManager sharedManager] getCurrentColorTab].pointSize;
    CGFloat diameter = [[SettingManager sharedManager] getCurrentColorTab].pointSize * 2;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect currentRect = CGRectMake(previewOffset, previewOffset, diameter, diameter/*kPreviewAreaSize, kPreviewAreaSize*/); // runningY
    CGContextAddEllipseInRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //CGColorRef color = [[SettingManager sharedManager] getCurrentColorTab].tabColor.CGColor; //[UIAppDelegate GSCopyMyColor];
    CGColorRef color = [self CGColorFromUIColor:[[SettingManager sharedManager] getCurrentColorTab].tabColor opacity:[[SettingManager sharedManager] getCurrentColorTab].opacity];
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetFillColorWithColor(context, color);
    currentRect = CGRectMake(previewOffset, previewOffset, diameter, diameter);
    
    // Thanks to Jay's formula, we only need to draw once
    CGContextAddEllipseInRect(context, currentRect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

@end
