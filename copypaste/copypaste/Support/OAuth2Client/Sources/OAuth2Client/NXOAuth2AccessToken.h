//
//  NXOAuth2AccessToken.h
//  OAuth2Client
//
//  Created by Ullrich Schäfer on 27.08.10.
//
//  Copyright 2010 nxtbgthng. All rights reserved. 
//
//  Licenced under the new BSD-licence.
//  See README.md in this reprository for 
//  the full licence.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>


@interface NXOAuth2AccessToken : NSObject <NSCoding> {
@private
	NSString *accessToken;
	NSString *refreshToken;
	NSDate *expiresAt;
}
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *refreshToken;
@property (nonatomic, readonly) NSDate *expiresAt;
@property (nonatomic, readonly) BOOL doesExpire;
@property (nonatomic, readonly) BOOL hasExpired;

+ (id)tokenWithResponseBody:(NSString *)responseBody;

- (id)initWithAccessToken:(NSString *)accessToken;
- (id)initWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiresAt:(NSDate *)expiryDate;	// designated


#pragma mark Keychain Support

//TODO: Support alternate KeyChain Locations
+ (NSString *)serviceNameWithProvider:(NSString *)provider;
+ (id)tokenFromDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)storeInDefaultKeychainWithServiceProviderName:(NSString *)provider;
- (void)removeFromDefaultKeychainWithServiceProviderName:(NSString *)provider;

@end
