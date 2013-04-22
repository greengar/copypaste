//
//  GSSSession.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol GSSSessionDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
- (void)didGetNearbyUserSucceeded:(NSArray *)listOfUsers;
- (void)didGetNearbyUserFailed:(NSError *)error;
@end

@interface GSSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

+ (GSSSession *) activeSession;
+ (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;
+ (BOOL)isAuthenticated;
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate;
- (void)logOut;
- (void)getNearbyUserWithDelegate:(id<GSSSessionDelegate>)delegate;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@property (nonatomic, assign) id<GSSSessionDelegate> delegate;
@end
