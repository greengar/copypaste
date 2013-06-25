//
//  WBViewControllerDev.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBViewControllerDev.h"
#import "CollaborativeViewController.h"
#import "GSButton.h"
#import "WBMenuItem.h" // TODO: This header file SHOULD be visible to developers using the SDK

@interface WBViewControllerDev ()

@property (copy) WBCompletionBlock saveToPhotoLibraryCompletionBlock;

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
    
    __block __weak WBViewControllerDev *blockSafeSelf = self;
    
    [board addMenuItem:[WBMenuItem itemWithSection:@"Navigation" name:@"Close drawing editor"/*@"Back to Organizer"*/ progressString:nil usingBlock:^(UIImage *image, WBCompletionBlock completionBlock) {
        
        [board doneEditing];
        
    }]];
    
    // PicCollage: "Save to Library"
    // Penultimate: "Save to Camera Roll"
    // Sketches: "Photo Library"
    // Smartboard: "Save to Photo Library"
    
    // TODO: `progressString` and the parameter to completionBlock() are currently not used.
    [board addMenuItem:[WBMenuItem itemWithSection:@"Saving" name:@"Save to Photo Library" progressString:@"Saving to Library..." usingBlock:^(UIImage *image, WBCompletionBlock completionBlock) {
        
        self.saveToPhotoLibraryCompletionBlock = completionBlock;
        
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, blockSafeSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to save image to Photos App"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
                [alert show];
        }
        
    }]];
    
    // Exit Board (Close drawing editor)
    
    // ## Saving
    
    // Save a Copy
    
    // Save to Photos App
    
    // Save to Evernote
    
    // Save to Google Drive
    
    // ## Sharing
    
    // Share on Facebook
    
    // Share on Twitter
    
    // Upload to Online Gallery
    
    // Send in Email
    
    // Send in iMessage/MMS
    
    // ## <blank section header>
    
    // Delete Page
    
    // Credits
    
    // Help/FAQs
    
    // Contact Us
    
    
    [board showMeWithAnimationFromController:self];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertView *alert;
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photos App"
                                          delegate:nil cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photos App"
                                          delegate:nil cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
    
    self.saveToPhotoLibraryCompletionBlock(@"Saved to Library!");
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
            [[GSSession activeSession] sendRoomData:room];
        }
    }];
}

@end
