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
    
	UIButton *useSDSDKButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [useSDSDKButton setTitle:@"Use SDK" forState:UIControlStateNormal];
    [useSDSDKButton setFrame:CGRectMake(0, 0, 80, 80)];
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
