//
//  WBViewControllerDev.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBViewControllerDev.h"
#import "CollaborativeViewController.h"
#import "GSButton.h"

@interface WBViewControllerDev ()

@end

@implementation WBViewControllerDev

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
    
    GSButton *useCollaborativeSDK = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GrayButtonStyle];
    [useCollaborativeSDK setTitle:@"Use Collaborative SDK" forState:UIControlStateNormal];
    useCollaborativeSDK.titleLabel.font = [UIFont systemFontOfSize:22];
    [useCollaborativeSDK setFrame:CGRectMake(0, 0, 300, 80)];
    [useCollaborativeSDK setCenter:CGPointMake(self.view.center.x, self.view.center.y + 100)];
    [useCollaborativeSDK addTarget:self action:@selector(useCollaborativeSDK)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useCollaborativeSDK];
}

- (void)useWhiteboardSDK {
    WBBoard *board = [[WBBoard alloc] init];
    [board setDelegate:self];
    [board showMeWithAnimationFromController:self];
}

- (void)useCollaborativeSDK {
    CollaborativeViewController *controller = [[CollaborativeViewController alloc] init];
    [controller setTitle:@"Collaborative SDK"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (NSString *)facebookId {
    return @"166165553554902";
}

- (void)doneEditingBoardWithResult:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)exportCurrentBoardData:(NSDictionary *)data {
    [[GSSession activeSession] createRoomWithName:@"Board"
                                        isPrivate:NO
                                      codeToEnter:nil
                                        shareWith:nil
                                            block:^(id object, NSError *error) {
        if (error || !object) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error description]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            GSRoom *room = (GSRoom *)object;
            [room setData:[NSMutableDictionary dictionaryWithDictionary:data]];
            [[GSSession activeSession] sendRoomDataToServer:room];
        }
    }];
}

@end
