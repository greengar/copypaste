//
//  Painting.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "Painting.h"
#import "MainPaintingView.h"
#import "WBUtils.h"
#import "SettingManager.h"

#define kBrushPixelStep			1.0
#define kBrushPixelStepLite		3.0

@implementation Painting

@synthesize canvasWidth = canvasWidth, canvasHeight = canvasHeight;
@synthesize UUID = UUID;

- (id) init {
    self = [super init];
    if (self) {
        autoSize = YES;
        retinaSupport = NO;
    }
    return self;
}

- (void) canvasSize {
    if (autoSize) {
        if (device == iPadDevice) {
            self.canvasWidth = 768;
            self.canvasHeight = 1024;
        } else if ((device == iPhone5Device) || (device == iPodTouch5Device)) {
            self.canvasWidth = 320;
            self.canvasHeight = 568;
        } else {
            self.canvasWidth = 320;
            self.canvasHeight = 480;
        }
    }
}

- (void) rotated90CanvasSize {
    if (autoSize) {
        if (device == iPadDevice) {
            self.canvasWidth = 1024;
            self.canvasHeight = 768;
        } else if ((device == iPhone5Device) || (device == iPodTouch5Device)) {
            self.canvasWidth = 568;
            self.canvasHeight = 320;
        } else {
            self.canvasWidth = 480;
            self.canvasHeight = 320;
        }
    }
}

- (void)updateSize:(int)width and:(int) height {
    self.canvasWidth = width;
    self.canvasHeight = height;
    autoSize = NO;
}

- (CGFloat *)copyColor {
    CGFloat *copy = (CGFloat *)malloc(4 * sizeof(CGFloat));
    copy[0] = components[0];
    copy[1] = components[1];
    copy[2] = components[2];
    copy[3] = components[3];
    
    return copy;
}

- (void)updateColor:(CGColorRef)color {
    const CGFloat *c = CGColorGetComponents(color);
	components[0] = c[0];
	components[1] = c[1];
	components[2] = c[2];
}

- (void)updateOpacity:(CGFloat)opacity {
    components[3] = opacity;
}

- (void)updatePointSize:(CGFloat)inPointSize {
    pointSize = inPointSize;
}

- (void)updateDevice:(GSDevice)inDevice {
    device = inDevice;
}

- (CGFloat *)getColor {
    return components;
}

- (CGFloat)getPointSize {
    return pointSize;
}

- (GSDevice)getDevice {
    return device;
}

- (CGFloat *)getColorFrom:(Painting*)p {
    
    [self canvasSize];
    [p canvasSize];
    
    CGFloat* color = [self copyColor];
    
    // this is a hack!
    color[3] = [[SettingManager sharedManager] getCurrentColorTab].opacity;
        
    float o = 1.0 - powf(1.0 - color[3], 1.0/(([self getPointSizeFrom:p]*[UIScreen mainScreen].scale)));
        
    color[3] = o;
    
    return color;
}

- (CGFloat)getPointSizeFrom:(Painting*)p {
    CGFloat k = 1.0f/[self getSuitableRatio:p];
    return 1.0f * k * [self getPointSize];
}

- (CGFloat*)convertPosition:(CGFloat*)pos from:(Painting*)p atCenter:(BOOL)center {
    
    [self canvasSize];
    [p canvasSize];
    
    CGFloat k = [self getSuitableRatio:p];
    CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
    pair[0] = pos[0];
    pair[1] = pos[1];
    
    if (center) {
        
    } else {
        pair[0] -= 1.0f * p.canvasWidth / 2;
        pair[1] -= 1.0f * p.canvasHeight / 2;
    }
    
    pair[0] *= 1.0f * k;
    pair[1] *= 1.0f * k;
    pair[0] += 1.0f * self.canvasWidth / 2;
    pair[1] += 1.0f * self.canvasHeight / 2;
    
    return pair;
}

- (CGFloat*)getDrawScopefrom:(Painting*)p {
    
    [self canvasSize];
    [p canvasSize];
    
    CGFloat * quad = (CGFloat *)malloc(4 * sizeof(CGFloat));
    CGFloat * topLeft = (CGFloat *)malloc(2 * sizeof(CGFloat));
    CGFloat * rightBottom = (CGFloat *)malloc(2 * sizeof(CGFloat));
    CGFloat * t_topLeft = (CGFloat *)malloc(2 * sizeof(CGFloat));
    CGFloat * t_rightBottom = (CGFloat *)malloc(2 * sizeof(CGFloat));
    topLeft[0] = -p.canvasWidth / 2.0f;
    topLeft[1] = -p.canvasHeight / 2.0f;
    rightBottom[0] = p.canvasWidth / 2.0f;
    rightBottom[1] = p.canvasHeight / 2.0f;
    t_topLeft = [self convertPosition:topLeft from:p atCenter:YES];
    t_rightBottom = [self convertPosition:rightBottom from:p atCenter:YES];
    quad[0] = t_topLeft[0];
    quad[1] = t_topLeft[1];
    quad[2] = t_rightBottom[0];
    quad[3] = t_rightBottom[1];
    free(topLeft);
    free(rightBottom);
    free(t_topLeft);
    free(t_rightBottom);
    return quad;
}

- (CGFloat*)rotatePosition:(CGFloat*)pos from:(Painting*)p byDegree:(int)degree atCenter:(BOOL)center {
    
    [self canvasSize];
    [p canvasSize];
    
    CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
    pair[0] = pos[0];
    pair[1] = pos[1];
    
    if (center) {
        
    } else {
        pair[0] -= 1.0f * p.canvasWidth / 2;
        pair[1] -= 1.0f * p.canvasHeight / 2;
    }
    
    CGFloat temp = 0;
    switch (degree) {
        case 90:
            temp = pair[0];
            pair[0] = -pair[1];
            pair[1] = temp;
            break;
        case 180:
            pair[0] = -pair[0];
            pair[1] = -pair[1];
            break; 
        case 270:
            temp = pair[0];
            pair[0] = -pair[1];
            pair[1] = -temp;
            break;
        default:
            break;
    }
    pair[0] += 1.0f * self.canvasWidth / 2;
    pair[1] += 1.0f * self.canvasHeight / 2;
    
    return pair;
}

- (CGFloat*)translatePositionToCenter:(CGFloat*)pos {
    
    [self canvasSize];
    
    CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
    pair[0] = pos[0];
    pair[1] = pos[1];
    pair[0] -= 1.0f * self.canvasWidth / 2;
    pair[1] -= 1.0f * self.canvasHeight / 2;
    
    return pair;
}

- (CGFloat)getSuitableRatio:(Painting*)p {
    
    [self canvasSize];
    [p canvasSize];
    
    CGFloat k1 = ((CGFloat)canvasHeight) * 1.0f / ((CGFloat)p.canvasHeight);
    CGFloat k2 = ((CGFloat)canvasWidth) * 1.0f / ((CGFloat)p.canvasWidth);
    
    CGFloat kMax = 0;
    CGFloat kMin = 0;
    if (k1 < k2) {
        kMax = k2;
        kMin = k1;
    }
    else {
        kMax = k1;
        kMin = k2;
    }
    
    if (canvasWidth > p.canvasWidth
        || canvasHeight > p.canvasHeight) {
        return kMin;
    }
    return kMax;
}

- (CGFloat)getRotated90PointSizeFrom:(Painting*)p {
    CGFloat k = [self getSuitableRotated90Ratio:p];
    return 1.0f * k * [self getPointSize];
}

- (CGFloat)getRotated90FontSizeFrom:(Painting*)p {
    return 0;
}

- (CGFloat)getSuitableRotated90Ratio:(Painting*)p {
    [self canvasSize];
    [p canvasSize];
    
    CGFloat k1 = canvasWidth * 1.0f / p.canvasHeight;
    CGFloat k2 = canvasHeight * 1.0f / p.canvasWidth;
    
    CGFloat kMax = 0;
    CGFloat kMin = 0;
    if (k1 < k2) {
        kMax = k2;
        kMin = k1;
    }
    else {
        kMax = k1;
        kMin = k2;
    }
    
    if (canvasHeight > p.canvasWidth
        || canvasWidth > p.canvasHeight) {
        return kMin;
    }
    return kMax;
}

- (CGFloat*)convertRotated90Position:(CGFloat*)pos from:(Painting*)p atCenter:(BOOL)center {
    [self canvasSize];
    [p canvasSize];
    
    CGFloat k = [self getSuitableRotated90Ratio:p];
    CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
    pair[0] = pos[0];
    pair[1] = pos[1];
    
    if(center) {

    } else {
        pair[0] -= 1.0f * p.canvasWidth / 2;
        pair[1] -= 1.0f * p.canvasHeight / 2;
    }
    pair[0] *= 1.0f * k;
    pair[1] *= 1.0f * k;
    pair[0] += 1.0f * self.canvasWidth / 2;
    pair[1] += 1.0f * self.canvasHeight / 2;
    
    return pair;
}

- (CGFloat*)translateRotated90PositionToCenter:(CGFloat*)pos {
    [self canvasSize];
    //[p canvasSize];
    
    CGFloat * pair = (CGFloat *)malloc(2 * sizeof(CGFloat));
    pair[0] = pos[0];
    pair[1] = pos[1];
    pair[0] -= 1.0f * self.canvasHeight / 2;
    pair[1] -= 1.0f * self.canvasWidth / 2;
    
    //DLog(@"translate (%f, %f) to (%f, %f)", pos[0], pos[1], pair[0], pair[1]);
    
    return pair;
}
- (CGFloat*)getRotated90DrawScopefrom:(Painting*)p {
    return nil;
}

- (BOOL) isEqual:(id)object {
    if([object isKindOfClass:[Painting class]]) {
        Painting *p = object;
        
        const CGFloat *c = [p getColor];
        CGFloat inPointSize = [p getPointSize];
        
        if(pointSize == inPointSize
           && components[0] == c[0]
           && components[1] == c[1]
           && components[2] == c[2]
           && components[3] == c[3]) {
            return YES;
        }
           
    }
    return NO;
}

- (BOOL)isEqualColor:(Painting*)p {
    const CGFloat *c = [p getColor];
    
    if(components[0] == c[0]
       && components[1] == c[1]
       && components[2] == c[2]
       && components[3] == c[3]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqualDevice:(Painting*)p {
    return device == [p getDevice];
}

- (BOOL)isBiggerDevice:(Painting*)p {
    return device == iPadDevice
    && ([p getDevice] == iPhoneDevice
     || [p getDevice] == iPodTouchDevice
     || [p getDevice] == iPhone5Device
     || [p getDevice] == iPodTouch5Device);
}

- (void)setRetinaDisplaySupport:(BOOL)retina {
    retinaSupport = retina;
}

- (BOOL)retinaDisplaySupport {
    return retinaSupport;
}

@end
