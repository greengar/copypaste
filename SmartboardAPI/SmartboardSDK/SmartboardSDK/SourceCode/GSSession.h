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

@protocol PFLogInViewControllerDelegate;
@protocol PFSignUpViewControllerDelegate;

@interface GSSession : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

// Get the active session
+ (GSSession *)activeSession;

// Get the current user, it's NIL if not authenticated
+ (GSUser *)currentUser;

// Besure to set App Id and App Secret before calling any other methods
+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret;

// Check if user is authenticated to Smartboard API App
+ (BOOL)isAuthenticated;

// Perform authentication process
// viewController: your root view controller
// delegate: callback holder for authentication process
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController
                                           delegate:(id<GSSessionDelegate>)delegate;

// Call to update user info
- (void)updateUserInfoFromSmartboardAPIWithBlock:(GSResultBlock)block;

// Log out of Smartboard API, now the [[GSSession currentUser] is NIL
- (void)logOutWithBlock:(GSResultBlock)block;

// Get all near by users
- (void)getNearbyUserWithBlock:(GSArrayResultBlock)block;

// Get current logged in username
- (NSString *)currentUserName;

// Register message receiver, from now [didReceiveMessageFrom:content:time:] will be called
// in order to catch new messages
- (void)registerMessageReceiver:(id<GSSessionDelegate>)delegate;

// Send message to the destination user
- (void)sendMessage:(NSObject *)messageContent toUser:(GSUser *)user;

// Remove the message from server, otherwise the message receiver may catch it again
- (void)removeMessageFromSender:(GSUser *)user atTime:(NSString *)messageTime;

// Perform query to the server to get data
// queryCondition is an Array of key-value:
// Syntax: @[@"username", @"Hector"] -> (username == Hector)
// Result will be returned as an Array of GSObject
- (void)queryClass:(NSString *)classname
             where:(NSArray *)queryCondition
             block:(GSArrayResultBlock)block;

// Perform update to the server to get data
// queryCondition is an Array of key-value:
// Syntax: @[@"username", @"Hector"] -> (username == Hector)
// valueToSet is an Array of key-value:
// Syntax: @[@"lastname", @"Zhao"] -> (lastname = Zhao)
// -> Update Hector's lastname to Zhao
- (void)updateClass:(NSString *)classname
               with:(NSArray *)valueToSet
              where:(NSArray *)queryCondition
              block:(GSResultBlock)block;

// Call this in your app delegate's [application:openURL:sourceApplication:annotation:]
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

// Call this in your app delegate's [application:handleOpenURL:]
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url;

// Call this in your app delegate's [applicationWillEnterForeground:]
- (void)applicationWillEnterForeground:(UIApplication *)application;

// Call this in your app delegate's [applicationDidEnterBackground:]
- (void)applicationDidEnterBackground:(UIApplication *)application;

// Call this in your app delegate's [applicationDidBecomeActive:]
- (void)applicationDidBecomeActive:(UIApplication *)application;

// Call this in your app delegate's [applicationWillTerminate:]
- (void)applicationWillTerminate:(UIApplication *)application;

// Call this in your app delegate's [application:RegisterForRemoteNotificationsWithDeviceToken:]
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

// Current logged in user
@property (nonatomic, retain) GSUser *currentUser;

// The GSSession's delegate
@property (nonatomic, assign) id<GSSessionDelegate> delegate;
@end
