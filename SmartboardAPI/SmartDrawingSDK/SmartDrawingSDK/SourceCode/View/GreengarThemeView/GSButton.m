//
//  GSButton.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSButton.h"

@implementation GSButton

+ (id)buttonWithType:(UIButtonType)buttonType themeStyle:(GSButtonStyle)style {
    UIButton *button = [super buttonWithType:buttonType];
    switch (style) {
        case BlackButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/blackButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case BlueButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/blueButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case GreenButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/greenButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case GrayButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/grayButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
            break;
        case OrangeButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/orangeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case TanButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/tanButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
            break;
        case WhiteButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"SmartDrawing.bundle/whiteButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    return button;
}
@end
