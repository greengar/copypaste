//
//  UIColor+String.m
// SmartDrawingSDK
//
//  Created by Elliot on 6/27/10.
//  Copyright 2010 GreenGar Studios. All rights reserved.
//

#import "UIColor+GSString.h"
#import "SDUtils.h"

@implementation UIColor (GSString)
- (NSString *)gsStringWithX:(float)x y:(float)y {
	CGColorRef color = [self CGColor];
	const CGFloat *components = CGColorGetComponents(color);
	NSString *string = [NSString stringWithFormat:@"%f|%f|%f|%f|%f|%f", components[0], components[1], components[2], components[3], x, y];
	//DLog(@"%@", string);
	// NOTE: alpha is always 1
	return string;
}

// error:(NSError **)error
+ (UIColor *)gsColorFromString:(NSString *)string x:(float *)x y:(float *)y {
	NSArray *components = [string componentsSeparatedByString:@"|"];
    
    if ([components count] != 6) {
        DLog(@"*** error when parsing color from string: %@", string);        
        return nil;
    }

	UIColor *color = [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
                                     green:[[components objectAtIndex:1] floatValue]
                                      blue:[[components objectAtIndex:2] floatValue]
                                     alpha:[[components objectAtIndex:3] floatValue]];
	*x = [[components objectAtIndex:4] floatValue];
	*y = [[components objectAtIndex:5] floatValue];
	return color;
}

- (NSString *)gsString {
    CGColorRef color = [self CGColor];
	const CGFloat *components = CGColorGetComponents(color);
	NSString *string = [NSString stringWithFormat:@"%f|%f|%f|%f", components[0], components[1], components[2], components[3]];
	return string;
}

+ (UIColor *)gsColorFromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@"|"];
    
    if ([components count] != 4) {
        DLog(@"*** error when parsing color from string: %@", string);
        return nil;
    }
    
	UIColor *color = [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
                                     green:[[components objectAtIndex:1] floatValue]
                                      blue:[[components objectAtIndex:2] floatValue]
                                     alpha:[[components objectAtIndex:3] floatValue]];
	return color;
}
@end
