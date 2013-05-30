//
//  SDSession.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDUtils.h"

@interface SDSession : NSObject

// Get the active session
+ (SDSession *)activeSession;

- (void)loadImageIntoSmartboardDrawingSDK:(UIImage *)image
                           fromController:(UIViewController *)controller
                                 delegate:(id<SDSessionDelegate>)delegate;

// The SDSession's delegate
@property (nonatomic, assign) id<SDSessionDelegate> delegate;
@end
