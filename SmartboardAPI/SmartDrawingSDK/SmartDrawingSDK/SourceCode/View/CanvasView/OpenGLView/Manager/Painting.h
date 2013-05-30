//
//  Painting.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define FLEXIBLE 1

typedef enum {
	iPhoneDevice = 0,
    iPhone5Device,
	iPodTouchDevice,
    iPodTouch5Device,
	iPadDevice,
    AndroidDevice
} GSDevice;

@interface Painting : NSObject {
    NSString* UUID;
    CGFloat	components[4];
    CGFloat pointSize;
    int canvasWidth;
    int canvasHeight;
    GSDevice device;
    BOOL autoSize;
    BOOL retinaSupport;
}

@property (nonatomic) int canvasWidth;
@property (nonatomic) int canvasHeight;
@property (nonatomic, retain) NSString* UUID;

- (void)updateColor:(CGColorRef)color;
- (void)updateOpacity:(CGFloat)opacity;
- (void)updatePointSize:(CGFloat)inPointSize;
- (void)updateDevice:(GSDevice)inDevice;
- (void)updateSize:(int)width and:(int) height;
- (void)setRetinaDisplaySupport:(BOOL)retina;

- (CGFloat*)copyColor;

- (CGFloat*)getColor;
- (CGFloat)getPointSize;

- (CGFloat*)getColorFrom:(Painting*)p;
- (CGFloat)getPointSizeFrom:(Painting*)p;

- (CGFloat)getSuitableRatio:(Painting*)p;
- (CGFloat*)convertPosition:(CGFloat*)pos from:(Painting*)p atCenter:(BOOL)center;
- (CGFloat*)getDrawScopefrom:(Painting*)p;
- (CGFloat*)rotatePosition:(CGFloat*)pos from:(Painting*)p byDegree:(int)degree atCenter:(BOOL)center;
- (CGFloat*)translatePositionToCenter:(CGFloat*)pos;

// Rotated part
- (CGFloat)getRotated90PointSizeFrom:(Painting*)p;
- (CGFloat)getRotated90FontSizeFrom:(Painting*)p;

- (CGFloat)getSuitableRotated90Ratio:(Painting*)p;
- (CGFloat*)convertRotated90Position:(CGFloat*)pos from:(Painting*)p atCenter:(BOOL)center;
- (CGFloat*)translateRotated90PositionToCenter:(CGFloat*)pos;
- (CGFloat*)getRotated90DrawScopefrom:(Painting*)p;

- (GSDevice)getDevice;
- (BOOL)retinaDisplaySupport;
- (BOOL)isEqualColor:(Painting*)p;
- (BOOL)isBiggerDevice:(Painting*)p;
- (BOOL)isEqualDevice:(Painting*)p;

@end
