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
@synthesize nearByUserList = _nearByUserList;
@synthesize recentUserList = _recentUserList;

+ (DataManager *)sharedManager {
    static DataManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [DataManager new]; });
    return sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.nearByUserList = [[NSMutableArray alloc] init];
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
        
        if (([firstDataType compare:@"public.text" options:NSCaseInsensitiveSearch] == NSOrderedSame) // Normal text
            || ([firstDataType compare:@"public.utf8-plain-text" options:NSCaseInsensitiveSearch] == NSOrderedSame) // UTF8 text
            || ([firstDataType compare:@"com.agilebits.onepassword" options:NSCaseInsensitiveSearch] == NSOrderedSame))  { // 1Password
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
            
        } else {
            @try { // Try to parse all other kinds of object, catch the exception and return nil if not parsable
                NSString *string = [NSString stringWithUTF8String:[data bytes]];
                return string;
            }
            @catch (NSException *exception) {
                DLog(@"Object from clipboard is not parsable");
                return nil;
            }
        }
    }
    return nil;
}

- (void)updateNearbyUsers:(NSArray *)nearbyList {
    [self.nearByUserList removeAllObjects];
    for (GSSUser *gsUser in nearbyList) {
        [self.nearByUserList addObject:gsUser];
    }
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
