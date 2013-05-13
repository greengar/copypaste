//
//  CPAppDelegate.m
//  copypaste
//
//  Created by Elliot Lee on 4/11/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "CPAppDelegate.h"

@implementation CPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GSSession setAppId:@"UWaDpuZfLQvFpgVmz4LLvAPsy6bX9XG3D0mQrd7F"
               appSecret:@"jDyQOfa5IbHiY5cHbY1kouJMMwZWgGWX6RQhApIy"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound]; 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[GSSession activeSession] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[GSSession activeSession] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[GSSession activeSession] applicationDidBecomeActive:application];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationApplicationDidBecomeActive object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[GSSession activeSession] applicationWillTerminate:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog();
    [[GSSession activeSession] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DLog();
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation  {
    if ([url isFileURL]) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:data forKey:@"content"];
        NSNotification *notification = [NSNotification notificationWithName:kNotificationOpenFileURL
                                                                     object:nil
                                                                   userInfo:dict];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    return [[GSSession activeSession] application:application
                                           openURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[GSSession activeSession] application:application
                                     handleOpenURL:url];
}

@end
