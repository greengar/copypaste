//
//  GSTheme.h
//  Collaborative SDK
//
//  Created by Elliot Lee on 4/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+GSExpanded.h"
#import "OHAttributedLabel.h"
#import "GSUtils.h"

@interface GSTheme : NSObject

+ (UIColor *)textFieldTextColor;
+ (UIFont *)textFieldFont;
+ (OHAttributedLabel *)logoWithSize:(CGFloat)size;

@end
