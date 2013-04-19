//
//  GSSUser.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSSUser.h"

@implementation GSSUser
@synthesize uid = _uid;
@synthesize username = _username;
@synthesize firstname = _firstname;
@synthesize lastname = _lastname;
@synthesize email = _email;
@synthesize avatarURLString = _avatarURLString;
@synthesize isAvatarCached = _isAvatarCached;
@synthesize avatarImage = _avatarImage;

- (id)initWithDictionary:(NSDictionary *)userInfo {
    if (self = [super init]) {
        self.uid = [userInfo objectForKey:@"uid"];
        self.username = [userInfo objectForKey:@"username"];
        self.firstname = [userInfo objectForKey:@"firstname"];
        self.lastname = [userInfo objectForKey:@"lastname"];
        self.email = [userInfo objectForKey:@"email"];
        self.avatarURLString = [userInfo objectForKey:@"avatar_url"];
        
        dispatch_async(dispatch_get_current_queue(), ^{
            if (self.avatarURLString) {
                NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.avatarURLString]];
                self.avatarImage = [UIImage imageWithData:avatarData];
                self.isAvatarCached = YES;
            }
        });
    }
    return self;
}

+ (GSSUser *)userInfoFromDictionary:(NSDictionary *)userInfo {
    return [[[self class] alloc] initWithDictionary:userInfo];
}

#define kGSSuid @"gssuid"
#define kGSSusername @"gssusername"
#define kGSSfirstname @"gssfirstname"
#define kGSSlastname @"gsslastname"
#define kGSSemail @"gssemail"
#define kGSSavatarURLString @"gssavatarurl"
#define kGSSavatarImage @"gssavatarimage"
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:kGSSuid];
	[aCoder encodeObject:self.username forKey:kGSSusername];
    [aCoder encodeObject:self.firstname forKey:kGSSfirstname];
    [aCoder encodeObject:self.lastname forKey:kGSSlastname];
    [aCoder encodeObject:self.email forKey:kGSSemail];
    [aCoder encodeObject:self.avatarURLString forKey:kGSSavatarURLString];
    if (self.isAvatarCached && self.avatarImage) {
        [aCoder encodeObject:self.avatarImage forKey:kGSSavatarImage];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		self.uid = [aDecoder decodeObjectForKey:kGSSuid];
		self.username = [aDecoder decodeObjectForKey:kGSSusername];
        self.firstname = [aDecoder decodeObjectForKey:kGSSfirstname];
        self.lastname = [aDecoder decodeObjectForKey:kGSSlastname];
        self.email = [aDecoder decodeObjectForKey:kGSSemail];
        self.avatarURLString = [aDecoder decodeObjectForKey:kGSSavatarURLString];
        self.avatarImage = [aDecoder decodeObjectForKey:kGSSavatarImage];
        if (self.avatarImage) {
            self.isAvatarCached = YES;
        }
	}
	return self;
}

@end
