//
//  GSSSession.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "CPLogInViewController.h"
#import "GSSUser.h"
#import "GSSUtils.h"

@protocol GSSSessionDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
- (void)didGetNearbyUserSucceeded:(NSArray *)listOfUsers;
- (void)didGetNearbyUserFailed:(NSError *)error;
- (void)didReceiveMessageFrom:(NSString *)userId content:(NSObject *)messageContent time:(NSString *)messageTime;
- (void)didUpdateClassSucceeded;
- (void)didUpdateClassFailed:(NSError *)error;
@end

@interface GSSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

+ (GSSSession *)activeSession;
+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret;
+ (BOOL)isAuthenticated;
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController delegate:(id<GSSSessionDelegate>)delegate;
- (void)logOut;
- (void)getNearbyUserWithDelegate:(id<GSSSessionDelegate>)delegate;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (NSString *)currentUserName;
- (void)addObserver:(id<GSSSessionDelegate>)delegate;
- (void)sendMessage:(NSObject *)messageContent toUser:(GSSUser *)user;
- (void)removeMessageFromSender:(GSSUser *)user atTime:(NSString *)messageTime;
- (void)updateClass:(NSString *)classname forKey:(NSString *)key withValue:(id)value where:(NSArray *)queryCondition delegate:(id<GSSSessionDelegate>)delegate;

@property (nonatomic, retain) GSSUser *currentUser;
@property (nonatomic, assign) id<GSSSessionDelegate> delegate;
@end
