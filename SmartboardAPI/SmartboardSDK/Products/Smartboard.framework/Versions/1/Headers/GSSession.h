//
//  GSSSession.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSUser.h"
#import "GSUtils.h"
#import "GSLogInViewController.h"


@protocol GSSessionDelegate
- (void)didLoginSucceeded;
- (void)didLoginFailed:(NSError *)error;
- (void)didReceiveMessageFrom:(NSString *)senderUID
                      content:(NSObject *)messageContent
                         time:(NSString *)messageTime;
@end

@interface GSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

+ (GSSession *)activeSession;
+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret;
+ (BOOL)isAuthenticated;

- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController
                                           delegate:(id<GSSessionDelegate>)delegate;
- (void)updateUserInfoFromSmartboardAPIWithBlock:(GSResultBlock)block;

- (void)logOutWithBlock:(GSResultBlock)block;
- (void)getNearbyUserWithBlock:(GSArrayResultBlock)block;

- (NSString *)currentUserName;

- (void)addObserver:(id<GSSessionDelegate>)delegate;
- (void)sendMessage:(NSObject *)messageContent toUser:(GSUser *)user;
- (void)removeMessageFromSender:(GSUser *)user atTime:(NSString *)messageTime;

- (void)queryClass:(NSString *)classname
             where:(NSArray *)queryCondition
             block:(GSArrayResultBlock)block;

- (void)updateClass:(NSString *)classname
               with:(NSArray *)valueToSet
              where:(NSArray *)queryCondition
              block:(GSResultBlock)block;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url;

- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

@property (nonatomic, retain) GSUser *currentUser;
@property (nonatomic, assign) id<GSSessionDelegate> delegate;
@end
