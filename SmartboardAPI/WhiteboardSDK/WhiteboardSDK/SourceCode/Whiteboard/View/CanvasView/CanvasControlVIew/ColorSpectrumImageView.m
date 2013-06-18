//
//  ColorPickerImageView.m
//  ColorPicker
//
//  Created by markj on 3/6/09.
//  Copyright 2009 Mark Johnson. All rights reserved.
//

#import "ColorSpectrumImageView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/CoreAnimation.h>
#import "ColorCircleView.h"
#import "SettingManager.h"
#import "WBBaseElement.h"
#import "TextElement.h"

@implementation ColorSpectrumImageView
@synthesize pickedColorDelegate = _pickedColorDelegate;

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        pickedColorDelegateArray = (NSMutableArray <ColorPickerImageViewDelegate> *) [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) touchesEvent:(NSSet*)touches {
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self]; //where image was tapped
    if (point.y >= 0 && point.x >= 0 && point.y < self.frame.size.height && point.x < self.frame.size.width) {
        UIColor * lastColor = [self getPixelColorAtLocation:point];
        [[SettingManager sharedManager] setCurrentColorTabWithColor:lastColor
                                                          atOffsetX:point.x
                                                          atOffsetY:point.y];
        
        for (int i = 0; i < [pickedColorDelegateArray count]; i++) {
            if ([[pickedColorDelegateArray objectAtIndex:i] respondsToSelector:@selector(colorPicked:)]) {
                [[pickedColorDelegateArray objectAtIndex:i] colorPicked:lastColor];
            }
        }
        [self setCircleX:point.x y:point.y color:lastColor];
    }
}       

- (void)setCircleX:(float)x y:(float)y color:(UIColor *)myColor {
    if (myColor == nil) {
        DLog(@"WARNING: color is nil");
    } else {
        if (!circle) {
            circle = [[ColorCircleView alloc] initWithFrame:CGRectMake(x-11, y-11, 22, 23)];
            circle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            [self addSubview:circle];
        } else {
            circle.frame = CGRectMake(x-11, y-11, 22, 23);
        }
        circle.circleColor = myColor;
        [circle setNeedsDisplay];
    }
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesEvent:touches];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesEvent:touches];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesEvent:touches];
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    if (cgctx == NULL || data == NULL) {
        // Initialize cgctx and data
        
        inImage = [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPrivate.png"].CGImage;
        
        // Create off-screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpha, Red, Green, Blue
        cgctx = [self createARGBBitmapContextFromImage:inImage];
        if (cgctx == NULL) { return nil; /* error */ }
        
        w = CGImageGetWidth(inImage);
        h = CGImageGetHeight(inImage);
        rect = CGRectMake(0, 0, w, h);
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(cgctx, rect, inImage);
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        data = CGBitmapContextGetData (cgctx);
    }
    
    if (data != NULL) {
        float x = point.x;
        float y = point.y;
    
        // offset locates the pixel in the data from x,y.
		// 4 for 4 bytes of data per pixel, w is width of one row of data.
        // use floor intead of round to tolerate extreme cases 
        // E.g (iPhone, if y = 159.5, round(y) = 160 >> offset is out of array bound
        //      floor(159.5) = 159
		int offset = 4*((w*floor(y))+floor(x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //              DLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        //return [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    return color;
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inputImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inputImage);
    size_t pixelsHigh = CGImageGetHeight(inputImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();//CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

- (void) registerDelegate:(id)delegate {
    if (!pickedColorDelegateArray) {
        pickedColorDelegateArray = (NSMutableArray <ColorPickerImageViewDelegate> *) [[NSMutableArray alloc] init];
    }
    if (delegate) {
        [pickedColorDelegateArray addObject:delegate];
    }
}

- (void)dealloc {
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    if (data) { free(data); }
    
    [pickedColorDelegateArray removeAllObjects];
}


@end