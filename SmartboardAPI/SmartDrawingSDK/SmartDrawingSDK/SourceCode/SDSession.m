//
//  SDSession.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDSession.h"
#import "MainPaintingView.h"
#import "CanvasElement.h"
#import "MainPaintingView.h"
#import "SettingManager.h"
#import "SDBoard.h"

static SDSession *activeSession = nil;

@interface SDSession()
@property (nonatomic, assign) UIViewController *rootController;
@property (nonatomic, strong) CanvasElement *rootView;
@end

@implementation SDSession

+ (SDSession *)activeSession {
    static SDSession *activeSession;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ activeSession = [SDSession new]; });
    return activeSession;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)presentSmartboardControllerFromController:(UIViewController *)controller
                                        withImage:(UIImage *)image
                                         delegate:(id<SDSessionDelegate>)delegate {
    self.delegate = delegate;
    self.rootController = controller;
    
    SDBoard *rootBoard = [[SDBoard alloc] init];
    [rootBoard setDelegate:self];
    [rootBoard setBackgroundImage:image];
    [controller presentViewController:rootBoard animated:YES completion:NULL];
}

- (void)doneEditingBoardWithResult:(UIImage *)image {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(doneEditingPhotoWithResult:)]) {
        if (self.rootController) {
            [self.rootController dismissViewControllerAnimated:YES completion:NULL];
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
