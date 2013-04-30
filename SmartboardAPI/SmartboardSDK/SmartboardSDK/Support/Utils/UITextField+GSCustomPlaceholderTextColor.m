//
//  UITextField+GSCustomPlaceholderTextColor.m
//  copypaste
//
//  Created by Elliot Lee on 4/27/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "UITextField+GSCustomPlaceholderTextColor.h"
#import "UIColor+GSExpanded.h"

static char const * const PlaceholderTextColorKey = "PlaceholderTextColor";

@implementation UITextField (GSCustomPlaceholderTextColor)

@dynamic placeholderTextColor;

- (UIColor *)placeholderTextColor
{
    return objc_getAssociatedObject(self, PlaceholderTextColorKey);
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    objc_setAssociatedObject(self, PlaceholderTextColorKey, placeholderTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void) drawPlaceholderInRect:(CGRect)rect {
    [self.placeholderTextColor setFill]; // light orange
    //FE8C0E
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
}

#pragma clang diagnostic pop

@end
