//
//  MySlider.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/25/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//

#import "CustomSlider.h"

#define THUMB_SIZE 10
#define EFFECTIVE_THUMB_SIZE 30 //20

@implementation CustomSlider

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
	CGRect bounds = self.bounds;
	bounds = CGRectInset(bounds, -10, -3); //-8
	return CGRectContainsPoint(bounds, point);
}

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
	return YES;
}

@end
