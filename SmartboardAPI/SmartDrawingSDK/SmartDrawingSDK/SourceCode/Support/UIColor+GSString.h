//
//  UIColor+String.h
// SmartDrawingSDK
//
//  Created by Elliot on 6/27/10.
//  Copyright 2010 GreenGar Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (GSString)
- (NSString *)gsStringWithX:(float)x y:(float)y;
+ (UIColor *)gsColorFromString:(NSString *)string x:(float *)x y:(float *)y;
- (NSString *)gsString;
+ (UIColor *)gsColorFromString:(NSString *)string;
@end
