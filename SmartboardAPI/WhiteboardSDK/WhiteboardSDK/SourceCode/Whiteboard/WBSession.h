//
//  WBSession.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBUtils.h"

@interface WBSession : NSObject <WBBoardDelegate>

/*
 Get the active session
 @result Return WBSesion: the active session
 */
+ (WBSession *)activeSession;

/*
 Show the Whiteboard Control
 @param controller UIViewController: your root view controller
 @param image UIImage: your image to be edited, pass nil to create a new image
 @param delegate id: callback holder to receive the result image
 */
- (void)presentSmartboardControllerFromController:(UIViewController *)controller
                                        withImage:(UIImage *)image
                                         delegate:(id<WBSessionDelegate>)delegate;

// The WBSession's delegate
@property (nonatomic, assign) id<WBSessionDelegate> delegate;
@end
