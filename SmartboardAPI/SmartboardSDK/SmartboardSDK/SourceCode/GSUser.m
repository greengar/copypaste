//
//  GSSUser.m
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSUser.h"
#import <Parse/Parse.h>
#import "GSUtils.h"

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
@synthesize lastLogInDate = _lastLogInDate;
@synthesize isFacebookUser = _isFacebookUser;
@synthesize facebookId = _facebookId;
@synthesize facebookScreenName = _facebookScreenName;

- (id)initWithPFUser:(PFUser *)pfUser {
    return [self initWithPFUser:pfUser cacheAvatar:YES];
}

- (id)initWithPFUser:(PFUser *)pfUser cacheAvatar:(BOOL)cache {
    if (self = [super init]) {
        self.uid = [pfUser objectId];
        self.username = [pfUser username];
        self.firstname = pfUser[@"firstname"];
        self.lastname = pfUser[@"lastname"];
        self.fullname = pfUser[@"fullname"];
        self.email = pfUser[@"email"];
        self.avatarURLString = pfUser[@"avatar_url"];
        self.location = pfUser[@"location"];
        self.lastLogInDate = pfUser[@"last_log_in"];
        self.isFacebookUser = [pfUser[@"facebook_linked"] boolValue];
        self.facebookId = pfUser[@"facebook_id"];
        self.facebookScreenName = pfUser[@"facebook_screen_name"];
        // DLog(@"Parse from %@ to %@", pfUser, self);
        if (cache) {
            [self cacheAvatar];
        }
    }
    return self;
}

- (void)parseDataFromPFUser:(PFUser *)pfUser {
    return [self parseDataFromPFUser:pfUser cacheAvatar:YES];
}

- (void)parseDataFromPFUser:(PFUser *)pfUser cacheAvatar:(BOOL)cache {
    self.uid = [pfUser objectId];
    self.username = [pfUser username];
    self.firstname = pfUser[@"firstname"];
    self.lastname = pfUser[@"lastname"];
    self.fullname = pfUser[@"fullname"];
    self.email = pfUser[@"email"];
    self.avatarURLString = pfUser[@"avatar_url"];
    self.location = pfUser[@"location"];
    self.lastLogInDate = pfUser[@"last_log_in"];
    self.isFacebookUser = [pfUser[@"facebook_linked"] boolValue];
    self.facebookId = pfUser[@"facebook_id"];
    self.facebookScreenName = pfUser[@"facebook_screen_name"];
    // DLog(@"Parse from %@ to %@", pfUser, self);
    
    if (cache) {
        [self cacheAvatar];
    }
}

- (void)cacheAvatar {
    dispatch_async(dispatch_get_current_queue(), ^{
        if (self.avatarURLString) {
            NSData *avatarData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.avatarURLString]];
            self.avatarImage = [UIImage imageWithData:avatarData];
            self.isAvatarCached = YES;
        }
    });
}

- (id)initWithGSUser:(GSUser *)gssUser {
    return [self initWithGSUser:gssUser cacheAvatar:YES];
}

- (id)initWithGSUser:(GSUser *)gssUser cacheAvatar:(BOOL)cache {
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
        self.lastLogInDate = gssUser.lastLogInDate;
        self.isFacebookUser = gssUser.isFacebookUser;
        self.facebookId = gssUser.facebookId;
        self.facebookScreenName = gssUser.facebookScreenName;
        // DLog(@"Parse from %@ to %@", gssUser, self);
        
        if (cache) {
            [self cacheAvatar];
        }
    }
    return self;
}

- (void)parseDataFromGSUser:(GSUser *)gsUser {
    return [self parseDataFromGSUser:gsUser cacheAvatar:YES];
}

- (void)parseDataFromGSUser:(GSUser *)gssUser cacheAvatar:(BOOL)cache {
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
    self.lastLogInDate = gssUser.lastLogInDate;
    self.isFacebookUser = gssUser.isFacebookUser;
    self.facebookId = gssUser.facebookId;
    self.facebookScreenName = gssUser.facebookScreenName;
    // DLog(@"Parse from %@ to %@", gssUser, self);
    
    if (cache) {
        [self cacheAvatar];
    }
}

- (NSString *)displayName {
    if (self.fullname) {
        return self.fullname;
    } else {
        return self.username;
    }
}

- (NSString *)distanceStringToUser:(GSUser *)user {
    float miles = [self.location distanceInMilesTo:user.location];
    if (miles < 0.1) {
        return [NSString stringWithFormat:@"%.0f ft", miles*5280];
    }
    return [NSString stringWithFormat:@"%.1f mi", miles];
}

- (NSString *)lastSeenTimeString {
    if (self.lastLogInDate) {
        return [GSUtils dateDiffFromDate:self.lastLogInDate];
    }
    return @"never seen";
}

- (void)updateWithPFUser:(PFUser *)pfUser block:(GSResultBlock)block {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [pfUser setObject:geoPoint forKey:@"location"];
        [pfUser setObject:[NSDate date] forKey:@"last_log_in"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self parseDataFromPFUser:pfUser];
        }];
    }];
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
