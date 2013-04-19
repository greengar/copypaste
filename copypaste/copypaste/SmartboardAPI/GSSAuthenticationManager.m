//
//  GSSAuthenticationManager.m
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSAuthenticationManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DataManager.h"
#import "GSSSession.h"

static GSSAuthenticationManager *shareManager = nil;
static NXOAuth2Client *oauth2Client;

@interface GSSAuthenticationManager()
- (void)registerEmailFailedWithErrorDescription:(NSString *)errorString;
- (void)registerEmailFailedWithError:(NSError *)error;
- (void)loginEmailFailedWithErrorDescription:(NSString *)errorString;
- (void)loginEmailFailedWithError:(NSError *)error;
- (void)loginFacebookEmailFailedWithErrorDescription:(NSString *)errorString;
- (void)loginFacebookEmailFailedWithError:(NSError *)error;
@property (nonatomic, retain) NSString *username, *password, *email;
@end

@implementation GSSAuthenticationManager
@synthesize delegate = _delegate;
@synthesize username = _username;
@synthesize password = _password;
@synthesize email = _email;

+ (GSSAuthenticationManager *)sharedManager {
    static GSSAuthenticationManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [GSSAuthenticationManager new]; });
    return sharedManager;
}

+ (BOOL) isAuthenticated {
    [[self oauthClient] setPersistent:YES];
    return ([[self oauthClient] accessToken] != nil);
}

- (id) init {
    self = [super init];
    if (self) {
        [[[self class] oauthClient] setDelegate:self];
    }
    return self;
}

- (void)registerWithEmail:(NSString *)email
                 username:(NSString *)username
                 password:(NSString *)password
                 delegate:(id<GSSAuthenticationDelegate>)delegate {
    self.delegate = delegate;
    self.email = email;
    self.username = username;
    self.password = password;
    authenticateAction = GSSActionRegisterWithEmail;
    [oauth2Client requestAccess];
}

- (void)logInWithEmail:(NSString *)email
              password:(NSString *)password
              delegate:(id<GSSAuthenticationDelegate>)delegate {
    self.delegate = delegate;
    self.email = email;
    self.password = password;
    authenticateAction = GSSActionLoginWithEmail;
    [oauth2Client requestAccess];
}

- (void)logInWithFacebookEmail:(NSString *)email
                      username:(NSString *)username
                      delegate:(id<GSSAuthenticationDelegate>)delegate {
    self.delegate = delegate;
    authenticateAction = GSSActionLoginWithFacebookEmail;
}

+ (NXOAuth2Client *)oauthClient {
    if (oauth2Client == nil) {
#if DEBUG
        NSAssert([GSSSession clientId] != nil, @"ERROR: please using [GSSSession setClientID:YOUR_APP_ID] to set App ID");
#endif
        
        oauth2Client = [[NXOAuth2Client alloc] initWithClientID:[GSSSession clientId]
                                                   clientSecret:[GSSSession clientSecret]
                                                   authorizeURL:[NSURL URLWithString:kGreengarEndpointLoginAuthorize]
                                                       tokenURL:[NSURL URLWithString:kGreengarEndpointLoginToken]
                                                       delegate:nil];
    }
    return oauth2Client;
}

- (void)oauthClientNeedsAuthentication:(NXOAuth2Client *)aClient {
    DLog();
    NSAssert(aClient == oauth2Client, @"Not equal", @"equal");
	[oauth2Client authenticateWithUsername:_email password:_password];
}

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client {
    DLog(@"oauthClientDidGetAccessToken: %@", client.accessToken);
    NSAssert(client == oauth2Client, @"Not equal", @"equal");
    if ([client.accessToken hasExpired]) {
        DLog(@"AccessToken expired: %@", client.accessToken);
        [client.accessToken removeFromDefaultKeychainWithServiceProviderName:kGreengarDomain];
        [client refreshAccessToken];
        return;
    }
    
    if (authenticateAction == GSSActionRegisterWithEmail) {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(registerWithEmail:succeeded:)]) {
            [self.delegate registerWithEmail:self succeeded:client];
        }
    } else if (authenticateAction == GSSActionLoginWithEmail) {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(logInWithEmail:succeeded:)]) {
            [self.delegate logInWithEmail:self succeeded:client];
        }
    } else if (authenticateAction == GSSActionLoginWithFacebookEmail) {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(logInWithFacebookEmail:succeeded:)]) {
            [self.delegate logInWithFacebookEmail:self succeeded:client];
        }
    }
}

- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client {
    DLog(@"");
}

- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error {
    DLog(@"");
    NSAssert(client == oauth2Client, @"Not equal", @"equal");
    if (authenticateAction == GSSActionRegisterWithEmail) {
        [self registerEmailFailedWithError:error];
    } else if (authenticateAction == GSSActionLoginWithEmail) {
        [self loginEmailFailedWithError:error];
    } else if (authenticateAction == GSSActionLoginWithFacebookEmail) {
        [self loginFacebookEmailFailedWithError:error];
    }
}

- (void)registerEmailFailedWithErrorDescription:(NSString *)errorString {
    NSError *error = nil;
    if (errorString) {
        error = [NSError errorWithDomain:nil
                                    code:0
                                userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                     forKey:NSLocalizedDescriptionKey]];
    }
    [self registerEmailFailedWithError:error];
}

- (void)registerEmailFailedWithError:(NSError *)error {
    if ([GSSAuthenticationManager isAuthenticated]) {
        // [[NSNotificationCenter defaultCenter] postNotificationName:GSAuthErrorSessionInvalid object:nil];
    } else {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(registerWithEmail:failed:)]) {
            [self.delegate registerWithEmail:self failed:error];
        }
    }
}

- (void)loginEmailFailedWithErrorDescription:(NSString *)errorString {
    NSError *error = nil;
    if (errorString) {
        error = [NSError errorWithDomain:nil
                                    code:0
                                userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                     forKey:NSLocalizedDescriptionKey]];
    }
    [self loginEmailFailedWithError:error];
}

- (void)loginEmailFailedWithError:(NSError *)error {
    if ([GSSAuthenticationManager isAuthenticated]) {
        // [[NSNotificationCenter defaultCenter] postNotificationName:GSAuthErrorSessionInvalid object:nil];
    } else {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(logInWithEmail:failed:)]) {
            [self.delegate logInWithEmail:self failed:error];
        }
    }
}

- (void)loginFacebookEmailFailedWithErrorDescription:(NSString *)errorString {
    NSError *error = nil;
    if (errorString) {
        error = [NSError errorWithDomain:nil
                                    code:0
                                userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                     forKey:NSLocalizedDescriptionKey]];
    }
    [self loginFacebookEmailFailedWithError:error];
}

- (void)loginFacebookEmailFailedWithError:(NSError *)error {
    if ([GSSAuthenticationManager isAuthenticated]) {
        // [[NSNotificationCenter defaultCenter] postNotificationName:GSAuthErrorSessionInvalid object:nil];
    } else {
        if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(logInWithFacebookEmail:failed:)]) {
            [self.delegate logInWithFacebookEmail:self failed:error];
        }
    }
}

- (void)logOut {
    
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (shareManager == nil) {
            shareManager = [super allocWithZone:zone];
            return shareManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
