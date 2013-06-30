//
//  GSButton.m
//  Whiteboard SDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "GSButton.h"

@implementation GSButton

+ (id)buttonWithType:(UIButtonType)buttonType themeStyle:(GSButtonStyle)style {
    UIButton *button = [super buttonWithType:buttonType];
    switch (style) {
        case BlackButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/BlackButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case BlueButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/BlueButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case GreenButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/GreenButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case GrayButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/GreyButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
            break;
        case OrangeButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/OrangeButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
            break;
        case TanButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/TanButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
                              forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
            break;
        case WhiteButtonStyle:
            [button setBackgroundImage:[[UIImage imageNamed:@"Whiteboard.bundle/WhiteButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]
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
