//
//  GSSRequest.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSRequest.h"
#import "SBJson.h"
#import "GSSEndpoint.h"
#import "GSSSession.h"
#import "GSSAuthenticationManager.h"
#import "NXOAuth2Connection.h"

@interface GSSRequest()

@property (nonatomic, retain) NSURLConnection *conn;

//Not assign value to endPoint yet
@property (nonatomic, retain) NSString *endPoint;

- (void)requestWithURL:(NSString *)URLString
            HTTPMethod:(NSString *)HTTPMethod
                params:(NSDictionary *)params;
- (void)uploadImageData:(NSData *)data
               delegate:(id)delegate
               callback:(SEL)callback;
- (void)requestEndWithError:(NSError *)error response:(id)response;
- (void)startConnection:(NSURLRequest *)request;

@end


@implementation GSSRequest
@synthesize params = _params;
@synthesize conn = _conn;
@synthesize endPoint = _endPoint;

- (id)initWithDelegate:(id)delegate callback:(SEL)callback {
    if ((self = [super init])) {
        _delegate = delegate;
        _callback = callback;
        _receivedData = [[NSMutableData alloc] init];
    }
    return self;
}

+ (GSSRequest *)requestWithURL:(NSString *)URLString
                    HTTPMethod:(NSString *)HTTPMethod
                        params:(NSDictionary *)params
                      delegate:(id)delegate
                      callback:(SEL)callback {
    GSSRequest *request = [[GSSRequest alloc] initWithDelegate:delegate callback:callback];
    request.params = params;
    [request requestWithURL:URLString HTTPMethod:HTTPMethod params:params];
    return request;
}

+ (GSSRequest *)requestWithEndPoint:(NSString *)endPoint
                         HTTPMethod:(NSString *)HTTPMethod
                             params:(NSDictionary *)params
                           delegate:(id)delegate
                           callback:(SEL)callback {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", kGreengarServerURL, endPoint];
    return [self requestWithURL:URLString
                     HTTPMethod:HTTPMethod
                         params:params
                       delegate:delegate
                       callback:callback];
}

+ (GSSRequest *)requestWithEndPoint:(NSString *)endPoint
                             params:(NSDictionary *)params
                           delegate:(id)delegate
                           callback:(SEL)callback {
    return [self requestWithEndPoint:endPoint
                          HTTPMethod:@"POST"
                              params:params
                            delegate:delegate
                            callback:callback];
}

- (void)requestWithURL:(NSString *)URLString
            HTTPMethod:(NSString *)HTTPMethod
                params:(NSDictionary *)params {
	
	NSURL *url = [NSURL URLWithString:URLString];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:HTTPMethod];
	
	NSString* charset = (NSString*)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
	[request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
	
	//application/x-www-form-urlencoded
    
    NSMutableString *httpPOSTBody = [NSMutableString string];
    
    for (NSString* key in params) {
        id value = [params objectForKey:key];
        [httpPOSTBody appendFormat:@"%@=%@", key, value];
        
        if (key != [[params allKeys] lastObject]) {
            [httpPOSTBody appendString:@"&"];
        }
    }
    
    [httpPOSTBody appendString:[NSString stringWithFormat:@"&client_id=%@", [GSSSession clientId]]];
    
	[request setHTTPBody:[httpPOSTBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self startConnection:request];
}

- (void)requestEndWithError:(NSError *)error response:(id)response {
    [_delegate performSelector:_callback withObject:self withObject:error];
}

#pragma mark Asynchronous request

static BOOL const asynchronous = YES;

- (void)startConnection:(NSMutableURLRequest *)request {
    
    if ([GSSAuthenticationManager isAuthenticated] == NO) {
        
        self.conn = [[NSURLConnection alloc] initWithRequest:request
                                                    delegate:self
                                            startImmediately:YES];
        
    } else {
        self.conn = (NSURLConnection *) [[NXOAuth2Connection alloc] initWithRequest:request
                                                                   requestParameters:nil
                                                                         oauthClient:[GSSAuthenticationManager oauthClient]
                                                                            delegate:self];
    }
    
    if (_conn == nil) {
        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] forKey:NSURLErrorFailingURLStringErrorKey];
        [info setObject:@"Could not open connection" forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:@"GSRequest" code:1 userInfo:info];
        [self requestEndWithError:error response:info];
    }
    
}

- (void)didFinishLoadingData:(NSData *)data {
    
    NSError *error = nil;
    // API fetch succeeded
    NSString *str = [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
    
    // Parse
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    id respondingObject = [jsonParser objectWithString:str
                                                 error:&error];
    
	if (error != nil) {
        [self requestEndWithError:error response:str];
        return;
	}
    
    
    if ([respondingObject isKindOfClass:[NSError class]] == NO) {
        id error_code_obj = [respondingObject valueForKey:@"status"];
        if ([error_code_obj isKindOfClass:[NSNumber class]]) {
            int error_code = [error_code_obj intValue];
            id result = [respondingObject objectForKey:@"result"];
            if (error_code == 200) {
                if (_delegate) {
                    [_delegate performSelector:_callback withObject:self withObject:result];
                }
                
            } else {
                //KONG: check for unauthorized error_code
                error = [NSError errorWithDomain:@"Error" code:error_code userInfo:
                         [NSDictionary dictionaryWithObject:result
                                                     forKey:NSLocalizedDescriptionKey]];
                [self requestEndWithError:error response:respondingObject];
            }
            
        } else {
            if (_delegate) {
                [_delegate performSelector:_callback withObject:self withObject:respondingObject];
            }
        }
	}
    
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    DLog();
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    DLog("%@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
    DLog();
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    DLog();
    [self requestEndWithError:error response:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog();
    [self didFinishLoadingData:_receivedData];
}

#pragma mark -
#pragma mark NXOAuth2Connection delegate methods

- (void)oauthConnection:(NXOAuth2Connection *)connection didFailWithError:(NSError *)error {
    [self requestEndWithError:error response:nil];
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didFinishWithData:(NSData *)data {
    [self didFinishLoadingData:_receivedData];
    //    [self release];
}


@end
