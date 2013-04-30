//
//  GSTheme.h
//  copypaste
//
//  Created by Elliot Lee on 4/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+GSExpanded.h"
#import "OHAttributedLabel.h"

#define kCPBackgroundColor ([UIColor colorWithHexString:@"E1CAA7"])
#define kCPPasteTextColor ([UIColor colorWithHexString:@"FA891F"])
#define kCPLightOrangeColor ([UIColor colorWithHexString:@"F7A058"])

@interface GSTheme : NSObject

+ (OHAttributedLabel *)logoWithSize:(CGFloat)size;

@end
