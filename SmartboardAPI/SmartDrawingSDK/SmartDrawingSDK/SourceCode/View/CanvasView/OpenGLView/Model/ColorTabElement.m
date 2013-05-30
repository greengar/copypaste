//
//  ColorTabElement.m
// SmartDrawingSDK
//
//  Created by Hector Zhao on 7/13/11.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "ColorTabElement.h"


@implementation ColorTabElement

@synthesize pointSize, opacity, tabColor, offsetXOnSpectrum, offsetYOnSpectrum;

-(id) initWithPointSize:(float)newPointSize opacity:(float)newOpacity color:(UIColor *)newColor {
	if ((self = [super init])) {
        // Dont show the indicator at first launch
		self.offsetXOnSpectrum = -50;
		self.offsetYOnSpectrum = -50;
		self.pointSize = newPointSize;
		self.opacity = newOpacity;
		self.tabColor = newColor;
	}
	return self;
}

@end
