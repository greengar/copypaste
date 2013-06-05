//
//  WBAppDelegate.h
//  WhiteboardSample
//
//  Created by Hector Zhao on 6/5/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBViewController;

@interface WBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WBViewController *viewController;

@end
