//
//  DataManager.m
//  copypaste
//
//  Created by Hector Zhao on 4/15/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "DataManager.h"
#import <Smartboard/Smartboard.h>

static DataManager *shareManager = nil;

@implementation DataManager
@synthesize availableUsers = _nearByUserList;

+ (DataManager *)sharedManager {
    static DataManager *sharedManager;
    static dispatch_once_t done;
    dispatch_once(&done, ^{ sharedManager = [DataManager new]; });
    return sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self.availableUsers = [[NSMutableArray alloc] init];
        self.receivedMessages = [[NSMutableArray alloc] init];
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
    [self.availableUsers removeAllObjects];
    for (GSUser *gssUser in nearbyList) {
        CPUser *user = [[CPUser alloc] initWithGSUser:gssUser cacheAvatar:YES];
        [self.availableUsers addObject:user];
    }
}

- (CPUser *)userById:(NSString *)uid {
    CPUser *desiredUser = nil;
    for (CPUser *user in self.availableUsers) {
        if ([user.uid isEqualToString:uid]) {
            desiredUser = user;
            break;
        }
    }
    return desiredUser;
}

- (void)getNumOfMessageFromUser:(CPUser *)fromUser toUser:(CPUser *)toUser {
    PFQuery *query = [PFQuery queryWithClassName:@"CopyAndPaste"];
    [query whereKey:@"sender_id" equalTo:fromUser.uid];
    [query whereKey:@"receiver_id" equalTo:toUser.uid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            fromUser.numOfCopyFromMe = [object[@"num_of_msg"] intValue];
            toUser.numOfPasteToMe = [object[@"num_of_msg"] intValue];
        }
    }];
}

- (void)pasteToUser:(CPUser *)user block:(GSResultBlock)block {
    NSObject *itemToPaste = [[DataManager sharedManager] getThingsFromClipboard];
    
    if (itemToPaste) {
        [[GSSession activeSession] sendMessage:itemToPaste toUser:user];
        user.numOfCopyFromMe++;
        
        NSMutableArray *sendCondition = [NSMutableArray new];
        [sendCondition addObject:@"sender_id"];
        [sendCondition addObject:[[[GSSession activeSession] currentUser] uid]];
        [sendCondition addObject:@"receiver_id"];
        [sendCondition addObject:[user uid]];
        
        NSMutableArray *valueToSet = [NSMutableArray new];
        [valueToSet addObject:@"num_of_msg"];
        [valueToSet addObject:[NSNumber numberWithInt:user.numOfCopyFromMe]];
        
        [[GSSession activeSession] updateClass:@"CopyAndPaste"
                                          with:valueToSet
                                         where:sendCondition
                                         block:^(BOOL succeed, NSError *error) {
                                             block(succeed, error);
                                         }];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can not paste"
                                                            message:[NSString stringWithFormat:@"Your clipboard is empty, please copy something to paste to %@!", user.fullname]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSArray *)sortedAvailableUsersByLocation {
    return self.availableUsers;
}

- (NSArray *)sortedAvailableUsersByName {
    NSArray *sortedByNameArray = [NSArray arrayWithArray:self.availableUsers];
    sortedByNameArray = [sortedByNameArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *displayName1 = [((CPUser *) obj1) displayName];
        NSString *displayName2 = [((CPUser *) obj2) displayName];
        return [displayName1 compare:displayName2];
    }];
    return sortedByNameArray;
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
