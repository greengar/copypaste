//
//  WBHistoryColorButton.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/18/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBHistoryColorButton.h"
#import "SettingManager.h"

@implementation WBHistoryColorButton
@synthesize index = _index;

- (void)drawRect:(CGRect)rect {
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    float colorSize = [[SettingManager sharedManager] getColorTabAtIndex:self.index].pointSize*1.5;
    UIColor *color = [[SettingManager sharedManager] getColorTabAtIndex:self.index].tabColor;
    float red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    alpha = [[SettingManager sharedManager] getColorTabAtIndex:self.index].opacity;
    UIColor *alphaColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    UIBezierPath* historyColorPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.frame.size.width-colorSize)/2,
                                                                                       (self.frame.size.height-colorSize)/2,
                                                                                       colorSize,
                                                                                       colorSize)];
    [alphaColor setFill];
    [historyColorPath fill];
    [strokeColor setStroke];
    historyColorPath.lineWidth = 2;
    [historyColorPath stroke];
}

@end
