//
//  GSSRequest.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2ConnectionDelegate.h"
#import "GSSAppInfo.h"

@interface GSSRequest : NSObject <NXOAuth2ConnectionDelegate> {
    id _delegate;
    SEL _callback;
    
    // Request info.
    // Use this delegate can get more info about which request is calling back.
    NSString *_endPoint;
    NSDictionary *_params;
    
    // Connection.
    NSURLConnection *_conn;
    NSMutableData *_receivedData;
}

@property (nonatomic, retain) NSDictionary *params;

// Main method for Greengar social network APIs
+ (GSSRequest *)requestWithEndPoint:(NSString *)endPoint
                             params:(NSDictionary *)params
                           delegate:(id)delegate
                           callback:(SEL)callback;

+ (GSSRequest *)requestWithEndPoint:(NSString *)endPoint
                         HTTPMethod:(NSString *)HTTPMethod
                             params:(NSDictionary *)params
                           delegate:(id)delegate
                           callback:(SEL)callback;

+ (GSSRequest *)requestWithURL:(NSString *)URLString
                    HTTPMethod:(NSString *)HTTPMethod
                        params:(NSDictionary *)params
                      delegate:(id)delegate
                      callback:(SEL)callback;

- (id)initWithDelegate:(id)delegate callback:(SEL)callback;
- (void)requestWithURL:(NSString *)URLString
            HTTPMethod:(NSString *)HTTPMethod
                params:(NSDictionary *)params;

@end
