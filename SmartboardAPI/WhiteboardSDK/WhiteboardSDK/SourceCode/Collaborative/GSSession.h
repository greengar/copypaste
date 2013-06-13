//
//  GSSession.h
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSUser.h"
#import "GSRoom.h"
#import "GSUtils.h"

@interface GSSession : NSObject

/* 
 Get the active session
 @result Return GSSesion: the active session
 */
+ (GSSession *)activeSession;

/*
 Get the current user
 @result Return GSUser: current user, nil if not authenticated
 */
+ (GSUser *)currentUser;

/*
 Get logged in user's username
 @result Return NSString: username
 */
- (NSString *)currentUserName;

/*
 Be sure to set App Id and App Secret before calling any other methods
 @param appId NSString: app id from your Dashboard
 @param appSecret NSString: app secret from your Dashboard
 */
+ (void)setAppId:(NSString *)appId appSecret:(NSString *)appSecret;

#pragma mark - Authentications
/*
 Check if user is authenticated to Smartboard API App
 @result Return BOOL: if user is authenticated
 */
+ (BOOL)isAuthenticated;

/* 
 Perform authentication process
 @param viewController UIViewController: your root view controller
 @param delegate id: callback holder for authentication process
 */
- (void)authenticateSmartboardAPIFromViewController:(UIViewController *)viewController
                                           delegate:(id<GSSessionDelegate>)delegate;

/* 
 Call to update user info
 @param block GSResultBlock: if update is successfully or failed with errors
 */
- (void)updateUserInfoFromSmartboardAPIWithBlock:(GSResultBlock)block;

/*
 Log out of Smartboard API, now the [[GSSession currentUser] is NIL
 @param block GSResultBlock: if log out is successfully or failed with errors
 */
- (void)logOutWithBlock:(GSResultBlock)block;

#pragma mark - Request Users
/*
 Get user by email
 @param email NSString: email string for search
 @param block GSArrayResultBlock: return array (NSArray) of GSUser match the email
 */
- (void)getUsersByEmail:(NSString *)email
                  block:(GSArrayResultBlock)block;

/*
 Get all near by users
 @param block GSArrayResultBlock: return array (NSArray) of GSUser nearby
 */
- (void)getNearbyUserWithBlock:(GSArrayResultBlock)block;

#pragma mark - Request Rooms
/*
 Register room data changed, from now on every time data of a room is changed on server
 the data inside this room in client will be changed
 */
- (void)registerRoomDataChanged:(GSRoom *)room withBlock:(GSEmptyBlock)block;

/*
 Unregister room data changed, from now on data won't be pulled from server anymore
 */
- (void)unregisterRoomDataChanged:(GSRoom *)room;

/*  
 Create a room
 @param roomName NSString: name of your room
 @param isPrivate BOOL: YES -> only you and list of sharedEmail can access
                        NO  -> everybody can access, then pass nil to sharedEmails
 @param sharedEmails NSArray: NSArray of emails (NSString) to be shared
    return NSString roomId 
 @param block GSSingleResultBlock: return the created GSRoom
 */
- (void)createRoomWithName:(NSString *)roomName
                 isPrivate:(BOOL)isPrivate
               codeToEnter:(NSString *)codeToEnter
                 shareWith:(NSArray *)sharedEmails
                     block:(GSSingleResultBlock)block;

/*
 Get all public rooms
 @param block GSArrayResultBlock: return array (NSArray) of public available room (GSRoom)
 */
- (void)getAllPublicRoomWithBlock:(GSArrayResultBlock)block;

/*
 Get all rooms that are shared with the current user
 */
- (void)getRoomShareWithMeWithBlock:(GSArrayResultBlock)block;

/*
 Get the room who has the code
 @param code NSString: the secret code to enter the room
 @param block GSSingleResultBlock: return the room (GSRoom) who matches the code
 */
- (void)getRoomWithCode:(NSString *)code block:(GSSingleResultBlock)block;

/*
 Send whole room data to the server
 It contains everything about a room which may be too large and complicated
 For better performance, should send only the new data within the suitable scope
 See [sendDataToServer:] for more information
 @param room GSRoom: the room that contain the data
 */
- (void)sendRoomDataToServer:(GSRoom *)room;

/*
 Send dictionary to server
 Send data directly to the URL under the hierarchy
 Make sure you specify the correct URL
 @param dict NSDictionary: data dictionary
 @param urlString NSString: URL string to store the data under the hierarchy
 */
- (void)sendDataToServer:(NSDictionary *)dict atURL:(NSString *)urlString;

#pragma mark - Access and Update Database
/*
 Perform query to the server to get data
 @param classname NSString: classname in your Database
 @param queryCondition NSArray: array of key-value:
    syntax: @[@"username", @"Hector"] -> where (username == Hector)
 @param block GSArrayResultBlock: return array (NSArray) of GSObject match the query
 */
- (void)queryClass:(NSString *)classname
             where:(NSArray *)queryCondition
             block:(GSArrayResultBlock)block;

/* 
 Perform update to the server to get data
 @param classname NSString: classname in your Database
 @param valueToSet NSArray: array of key-value:
    syntax: @[@"firstname", @"Hector"] -> set firstname to Hector
 @param queryCondition NSArray: array of key-value:
    Syntax: @[@"username", @"Hector"] -> where (username == Hector)
 @param block GSResultBlock: if update is successfully or failed with errors
 */
- (void)updateClass:(NSString *)classname
               with:(NSArray *)valueToSet
              where:(NSArray *)queryCondition
              block:(GSResultBlock)block;

#pragma mark - Peer-to-Peer Messages
/*
 Register message receiver, from now [didReceiveMessage:(NSDictionary *)dictInfo]
 will be called in order to catch new messages
 @param delegate id<GSMessageDelegate>: callback holder to receive [didReceiveMessage:(NSDictionary *)dictInfo]
 */
- (void)registerMessageReceiver:(id<GSMessageDelegate>)delegate;

/*
 Send message dictionary key-value to the destination user
 @param dictionary NSDictionary: dictionary of key-value to send
    syntax: @{@"receiver" : @"Hector", @"content" : @"Hello"}
 @param user GSUser: destination of the message
 @param block GSResultBlock: if message is sent successfully or failed with errors
 */
- (void)sendData:(NSDictionary *)dictionary toUser:(GSUser *)user withBlock:(GSResultBlock)block;

/* 
 Remove the message from server, otherwise the message receiver may catch it again
 @param user GSUser: remove message from this user
 @param messageTime NSString: message time string
 */
- (void)removeMessageFromSender:(GSUser *)user atTime:(NSString *)messageTime;

#pragma mark - Push Notifications
/*
 Send push notification message to user
 @param message NSString: message content for Push Notification
 @param user GSUser: destination of the Push Notification
 */
- (void)sendPushNotificationMessage:(NSString *)message toUser:(GSUser *)user;

#pragma mark - Lifecycle
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

// Call this in your app delegate's [application:didReceiveRemoteNotification:]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

// Current logged in user
@property (nonatomic, retain) GSUser *currentUser;

// The GSSession's delegate
@property (nonatomic, assign) UIViewController *authenticationController;
@property (nonatomic, assign) id<GSSessionDelegate> delegate;
@property (nonatomic, assign) id<GSMessageDelegate> msgDelegate;
@property (nonatomic, assign) id<GSRoomDelegate> roomDelegate;
@end
