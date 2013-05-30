//
//  SDSession.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDSession.h"
#import "MainPaintingView.h"
#import "CanvasView.h"
#import "MainPaintingView.h"
#import "SettingManager.h"

static SDSession *activeSession = nil;

@interface SDSession()
@property (nonatomic, strong) CanvasView *rootView;
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

- (void)loadImageIntoSmartboardDrawingSDK:(UIImage *)image
                           fromController:(UIViewController *)controller
                                 delegate:(id<SDSessionDelegate>)delegate {
    self.delegate = delegate;
    
    // OpenGL View
	self.rootView = [[CanvasView alloc] initWithFrame:controller.view.frame image:image];
    [controller.view addSubview:self.rootView];
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
