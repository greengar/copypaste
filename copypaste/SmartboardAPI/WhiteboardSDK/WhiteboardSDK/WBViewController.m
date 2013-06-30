//
//  WBViewController.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBViewController.h"
#import "GSButton.h"

@interface WBViewController ()

@end

@implementation WBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:253.f/255 green:198.f/255 blue:137.f/255 alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
    label.text = @"Drawing App";
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Futura-Medium" size:42];
    label.center = CGPointMake(self.view.center.x, self.view.center.y - 120);
    [self.view addSubview:label];
    
	GSButton *useWhiteboardSDK = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GrayButtonStyle];
    [useWhiteboardSDK setTitle:@"Start Drawing" forState:UIControlStateNormal];
    useWhiteboardSDK.titleLabel.font = [UIFont systemFontOfSize:22];
    [useWhiteboardSDK setFrame:CGRectMake(0, 0, 300, 80)];
    [useWhiteboardSDK setCenter:self.view.center];
    [useWhiteboardSDK addTarget:self action:@selector(useWhiteboardSDK)
               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useWhiteboardSDK];
}

- (void)useWhiteboardSDK {
    WBBoard *board = [[WBBoard alloc] init];
    [board setDelegate:self];
    [board showMeWithAnimationFromController:self];
}

- (void)doneEditingBoardWithResult:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

@end
