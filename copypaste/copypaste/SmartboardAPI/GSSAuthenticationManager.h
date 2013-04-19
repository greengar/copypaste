//
//  GSSAuthenticationManager.h
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPUser.h"
#import "NXOAuth2.h"
#import "GSSParseQueryHelper.h"

typedef enum {
    GSSActionNone = 0,
    GSSActionRegisterWithEmail,
    GSSActionLoginWithEmail,
    GSSActionLoginWithFacebookEmail
} GSSAuthenticationAction;

@class GSSAuthenticationManager;

@protocol GSSAuthenticationDelegate
@optional
- (void) registerWithEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient;
- (void) registerWithEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error;
- (void) logInWithEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient;
- (void) logInWithEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error;
- (void) logInWithFacebookEmail:(GSSAuthenticationManager *)auth succeeded:(NXOAuth2Client *)oauthClient;
- (void) logInWithFacebookEmail:(GSSAuthenticationManager *)auth failed:(NSError *)error;
@end

@interface GSSAuthenticationManager : NSObject <NXOAuth2ClientDelegate> {
    GSSAuthenticationAction authenticateAction;
}

+ (GSSAuthenticationManager *) sharedManager;
+ (BOOL) isAuthenticated;
- (void) registerWithEmail:(NSString *)email
                  username:(NSString *)username
                  password:(NSString *)password
                  delegate:(id<GSSAuthenticationDelegate>)delegate;
- (void) logInWithEmail:(NSString *)email
               password:(NSString *)password
               delegate:(id<GSSAuthenticationDelegate>)delegate;
- (void) logInWithFacebookEmail:(NSString *)email
                       username:(NSString *)username
                       delegate:(id<GSSAuthenticationDelegate>)delegate;
- (void) logOut;
+ (NXOAuth2Client *)oauthClient;

@property (nonatomic, assign) id<GSSAuthenticationDelegate> delegate;

@end
