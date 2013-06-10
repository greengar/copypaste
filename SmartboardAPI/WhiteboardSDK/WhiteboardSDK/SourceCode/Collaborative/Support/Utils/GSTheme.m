//
//  GSTheme.m
//  copypaste
//
//  Created by Elliot Lee on 4/29/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSTheme.h"
#import "NSAttributedString+Attributes.h"

@implementation GSTheme

+ (OHAttributedLabel *)logoWithSize:(CGFloat)size
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedStringWithString:@"copypaste"];
    // Since we don't specify a range, these affect the whole string
    [str setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByCharWrapping];
    [str setFont:[UIFont fontWithName:@"Heiti SC" size:size]];
    [str setTextColor:kCPPasteTextColor];
    // Change the color of "copy"
    [str setTextColor:[UIColor colorWithHexString:@"CC5213"] range:NSMakeRange(0, 4)];
    OHAttributedLabel *label = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 70, 320, 54)];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = str;
    return label;
}

@end
