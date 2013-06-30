//
//  WBViewController.m
//  WhiteboardSample
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
    
    int buttonSize = 80;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((self.view.frame.size.width-buttonSize)/2,
                                (self.view.frame.size.height-buttonSize)/2,
                                buttonSize,
                                buttonSize)];
    [button setTitle:@"Use SDK" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(useSDK) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)useSDK {
    [[WBSession activeSession] presentSmartboardControllerFromController:self
                                                               withImage:nil // Replace with the image you want
                                                                delegate:self];
}

- (void)doneEditingPhotoWithResult:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Image Saved"
                                                        message:@"Please go to your Photos App to see it"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end