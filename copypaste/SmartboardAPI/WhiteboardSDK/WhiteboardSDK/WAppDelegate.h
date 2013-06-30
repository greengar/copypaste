//
//  WAppDelegate.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSSession.h"

#if DEV
    @class WBViewControllerDev;
#else
    @class WBViewController;
#endif

@interface WAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

#if DEV
    @property (strong, nonatomic) WBViewControllerDev *viewController;
#else
    @property (strong, nonatomic) WBViewController *viewController;
#endif

@end
