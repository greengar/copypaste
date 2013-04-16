//
//  EGOImageLoadConnection.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 12/1/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOImageLoadConnection.h"


@implementation EGOImageLoadConnection
@synthesize imageURL=_imageURL, response=_response, delegate=_delegate, timeoutInterval=_timeoutInterval;

#if __EGOIL_USE_BLOCKS
@synthesize handlers;
#endif

- (id)initWithImageURL:(NSURL*)aURL delegate:(id)delegate {
	if((self = [super init])) {
		_imageURL = [aURL retain];
		self.delegate = delegate;
		_responseData = [[NSMutableData alloc] init];
		self.timeoutInterval = 30;
		
		#if __EGOIL_USE_BLOCKS
		handlers = [[NSMutableDictionary alloc] init];
		#endif
	}
	
	return self;
}

- (void)start {
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL
																cachePolicy:NSURLRequestReturnCacheDataElseLoad
															timeoutInterval:self.timeoutInterval];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];  
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[request release];
    
    //ELLIOT: track download time
#if DL_DEBUG
    DLog(@"Image downloading...");
    
    /* Get the timebase info */
    mach_timebase_info(&info);
    
    start = mach_absolute_time();
    
    /* Do some code */
#endif
}

- (void)cancel {
	[_connection cancel];	
}

- (NSData*)responseData {
	return _responseData;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(connection != _connection) return;
	[_responseData appendData:data];
    
#if DL_DEBUG
    DLog(@"didReceiveData: %u bytes", [data length]);
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if(connection != _connection) return;
	self.response = response;
    
#if DL_DEBUG
    DLog(@"didReceiveResponse:%@", response);
#endif
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if(connection != _connection) return;

	if([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]) {
		[self.delegate imageLoadConnectionDidFinishLoading:self];
	}
    
#if DL_DEBUG
    uint64_t duration = mach_absolute_time() - start;
    
    /* Convert to nanoseconds */
    duration *= info.numer;
    duration /= info.denom;
    
    /* Convert to seconds */
    double seconds = duration / 1000000000.0;
    
    /* Log the time */
    DLog(@"Image downloaded in: %lf sec (%u bytes)", seconds, [_responseData length]);
#endif
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if(connection != _connection) return;

	if([self.delegate respondsToSelector:@selector(imageLoadConnection:didFailWithError:)]) {
		[self.delegate imageLoadConnection:self didFailWithError:error];
	}
    
#if DL_DEBUG
    DLog(@"didFailWithError:%@", error);
#endif
}


- (void)dealloc {
	self.response = nil;
	self.delegate = nil;
	
	#if __EGOIL_USE_BLOCKS
	[handlers release], handlers = nil;
	#endif

	[_connection release];
	[_imageURL release];
	[_responseData release];
	[super dealloc];
}

@end
