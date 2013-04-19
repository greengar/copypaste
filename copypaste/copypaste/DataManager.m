//
//  DataManager.m
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "DataManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GSSSession.h"

static DataManager *shareManager = nil;

@implementation DataManager
@synthesize myUser = _myUser;
@synthesize nearByUserList = _nearByUserList;
@synthesize recentUserList = _recentUserList;

+ (DataManager *)sharedManager {
    static DataManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [DataManager new]; });
    return sharedManager;
}

+ (BOOL) isAuthenticated {
    return [GSSAuthenticationManager isAuthenticated];
}

- (id) init {
    self = [super init];
    if (self) {
        self.myUser = [[CPUser alloc] init];
        [GSSSession setClientId:@"copypaste"];
        [GSSSession setClientSecret:@"copypaste"];
        
        self.nearByUserList = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            CPUser *user = [[CPUser alloc] init];
            user.avatarURLString = @"http://cdn.theatlantic.com/static/mt/assets/science/Screen%20Shot%202012-08-29%20at%201.45.48%20PM.png";
            user.username = [NSString stringWithFormat:@"user %d", i];
            [self.nearByUserList addObject:user];
        }
        self.recentUserList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSObject *)getThingsFromClipboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSArray *passboardTypes = [pasteboard pasteboardTypes];
    if ([passboardTypes count] > 0) {
        NSString *firstDataType = [passboardTypes objectAtIndex:0];
        NSData *data = [pasteboard dataForPasteboardType:firstDataType];
        DLog(@"Data type: %@", firstDataType);
        
        if (([firstDataType compare:@"public.text" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            || ([firstDataType compare:@"public.utf8-plain-text" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            return string;
            
        } else if (([firstDataType compare:@"public.jpeg" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([firstDataType compare:@"public.jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([firstDataType compare:@"public.png" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
            UIImage *image = [UIImage imageWithData:data];
            return image;
            
        } else if ([firstDataType compare:@"com.apple.mobileslideshow.asset-object-id-uri" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            UIImage *image = pasteboard.image;
            return image;
            
        }
            
    }
    return nil;
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
