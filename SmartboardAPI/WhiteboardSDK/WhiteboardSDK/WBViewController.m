//
//  WBViewController.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBViewController.h"

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
    
	UIButton *useSDSDKButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [useSDSDKButton setTitle:@"Start Drawing" forState:UIControlStateNormal];
    useSDSDKButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [useSDSDKButton setFrame:CGRectMake(0, 0, 300, 80)];
    [useSDSDKButton setCenter:self.view.center];
    [useSDSDKButton addTarget:self action:@selector(useSDK) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useSDSDKButton];
    
}

- (void)useSDK {
    [[WBSession activeSession] presentSmartboardControllerFromController:self
                                                               withImage:nil
                                                                delegate:self];
}

- (void)doneEditingPhotoWithResult:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
