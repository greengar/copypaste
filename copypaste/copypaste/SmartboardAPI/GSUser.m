//
//  GSSUser.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSUser.h"

@implementation GSUser
@synthesize uid = _uid;
@synthesize username = _username;
@synthesize firstname = _firstname;
@synthesize lastname = _lastname;
@synthesize fullname = _fullname;
@synthesize email = _email;
@synthesize avatarURLString = _avatarURLString;
@synthesize isAvatarCached = _isAvatarCached;
@synthesize avatarImage = _avatarImage;
@synthesize location = _location;

- (id)initWithPFUser:(PFUser *)pfUser {
    if (self = [super init]) {
        self.uid = [pfUser objectId];
        self.username = [pfUser username];
        self.firstname = pfUser[@"firstname"];
        self.lastname = pfUser[@"lastname"];
        self.fullname = pfUser[@"fullname"];
        self.email = pfUser[@"email"];
        self.avatarURLString = pfUser[@"avatar_url"];
        self.location = pfUser[@"location"];
        DLog(@"Parse from %@ to %@", pfUser, self);
        
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

- (void)parseDataFromPFUser:(PFUser *)pfUser {
    self.uid = [pfUser objectId];
    self.username = [pfUser username];
    self.firstname = pfUser[@"firstname"];
    self.lastname = pfUser[@"lastname"];
    self.fullname = pfUser[@"fullname"];
    self.email = pfUser[@"email"];
    self.avatarURLString = pfUser[@"avatar_url"];
    self.location = pfUser[@"location"];
    DLog(@"Parse from %@ to %@", pfUser, self);
    
    dispatch_async(dispatch_get_current_queue(), ^{
        if (self.avatarURLString) {
            NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.avatarURLString]];
            self.avatarImage = [UIImage imageWithData:avatarData];
            self.isAvatarCached = YES;
        }
    });
}

- (id)initWithGSUser:(GSUser *)gssUser {
    if (self = [super init]) {
        self.uid = gssUser.uid;
        self.username = gssUser.username;
        self.firstname = gssUser.firstname;
        self.lastname = gssUser.lastname;
        self.fullname = gssUser.fullname;
        self.email = gssUser.email;
        self.avatarURLString = gssUser.avatarURLString;
        self.location = gssUser.location;
        self.avatarImage = gssUser.avatarImage;
        self.isAvatarCached = gssUser.isAvatarCached;
        DLog(@"Parse from %@ to %@", gssUser, self);
    }
    return self;
}

- (void)parseDataFromGSUser:(GSUser *)gssUser {
    self.uid = gssUser.uid;
    self.username = gssUser.username;
    self.firstname = gssUser.firstname;
    self.lastname = gssUser.lastname;
    self.fullname = gssUser.fullname;
    self.email = gssUser.email;
    self.avatarURLString = gssUser.avatarURLString;
    self.location = gssUser.location;
    self.avatarImage = gssUser.avatarImage;
    self.isAvatarCached = gssUser.isAvatarCached;
    DLog(@"Parse from %@ to %@", gssUser, self);
}

- (NSString *)distanceStringToUser:(GSUser *)user {
    float miles = [self.location distanceInMilesTo:user.location];
    if (miles < 0.1) {
        return [NSString stringWithFormat:@"%.0f ft", miles*5280];
    }
    return [NSString stringWithFormat:@"%.1f mi", miles];
}

+ (GSUser *)userInfoFromDictionary:(NSDictionary *)userInfo {
    return [[[self class] alloc] initWithDictionary:userInfo];
}

#define kGSSuid @"gssuid"
#define kGSSusername @"gssusername"
#define kGSSfirstname @"gssfirstname"
#define kGSSlastname @"gsslastname"
#define kGSSfullname @"gssfullname"
#define kGSSemail @"gssemail"
#define kGSSavatarURLString @"gssavatarurl"
#define kGSSavatarImage @"gssavatarimage"
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.uid forKey:kGSSuid];
	[aCoder encodeObject:self.username forKey:kGSSusername];
    [aCoder encodeObject:self.firstname forKey:kGSSfirstname];
    [aCoder encodeObject:self.lastname forKey:kGSSlastname];
    [aCoder encodeObject:self.fullname forKey:kGSSfullname];
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
        self.fullname = [aDecoder decodeObjectForKey:kGSSfullname];
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
