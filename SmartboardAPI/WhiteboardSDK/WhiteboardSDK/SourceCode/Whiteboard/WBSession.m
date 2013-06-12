//
//  WBSession.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBSession.h"
#import "MainPaintingView.h"
#import "CanvasElement.h"
#import "MainPaintingView.h"
#import "SettingManager.h"
#import "BoardManager.h"
#import "WBBoard.h"

static WBSession *activeSession = nil;

@interface WBSession()
@property (nonatomic, assign) UIViewController *rootController;
@property (nonatomic, strong) CanvasElement *rootView;
@end

@implementation WBSession

+ (WBSession *)activeSession {
    static WBSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [WBSession new]; });
    return activeSession;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

static const NSTimeInterval WBSessionAnimationDuration = 0.5;

- (void)presentSmartboardControllerFromController:(UIViewController *)controller
                                        withImage:(UIImage *)image
                                         delegate:(id<WBSessionDelegate>)delegate {
    self.delegate = delegate;
    self.rootController = controller;
    
    WBBoard *rootBoard = [[WBBoard alloc] init];
    [rootBoard setBackgroundImage:image];
    [rootBoard setDelegate:self];
    [controller presentViewController:rootBoard animated:NO completion:NULL];
    
    [UIView beginAnimations:kCurlUpAndDownAnimationID context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                           forView:[UIApplication sharedApplication].keyWindow
                             cache:YES];
    [UIView setAnimationDuration:WBSessionAnimationDuration];
    [UIView commitAnimations];
    
    [[BoardManager sharedManager] createANewBoard:rootBoard];
}

- (void)doneEditingBoardWithResult:(UIImage *)image {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneEditingPhotoWithResult:)]) {
        if (self.rootController) {
            
            // Use Animated:NO here; otherwise this creates a weird artifact
            // with shorter animation durations < ~1.0
            [self.rootController dismissViewControllerAnimated:NO completion:NULL];
            
            [UIView beginAnimations:kCurlUpAndDownAnimationID context:nil];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                                   forView:[UIApplication sharedApplication].keyWindow
                                     cache:YES];
            [UIView setAnimationDuration:WBSessionAnimationDuration];
            [UIView commitAnimations];
        }
        [self.delegate doneEditingPhotoWithResult:image];
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (activeSession == nil) {
            activeSession = [super allocWithZone:zone];
            return activeSession;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
