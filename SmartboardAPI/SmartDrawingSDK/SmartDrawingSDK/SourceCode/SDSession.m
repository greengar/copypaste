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
#import "SDBoard.h"

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

- (void)presentSmartboardControllerFromController:(UIViewController *)controller
                                        withImage:(UIImage *)image
                                         delegate:(id<SDSessionDelegate>)delegate {
    self.delegate = delegate;

    SDBoard *rootController = [[SDBoard alloc] init];
    [rootController setDelegate:self];
    [controller presentViewController:rootController animated:YES completion:NULL];
}

- (void)editPhotoFinished:(UIImage *)image {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(editPhotoFinished:)]) {
        [self.delegate editPhotoFinished:image];
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
