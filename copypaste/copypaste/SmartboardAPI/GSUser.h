//
//  GSSUser.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "GSUtils.h"

@class GSUser;

@protocol GSSUser
+ (GSUser *)userInfoFromDictionary:(NSDictionary *)userInfo;
@end

@interface GSUser : NSObject <GSSUser, NSCoding>

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *avatarURLString;
@property (nonatomic)         BOOL isAvatarCached;
@property (nonatomic, retain) UIImage *avatarImage;
@property (nonatomic, retain) PFGeoPoint *location;
@property (nonatomic, retain) NSDate *lastLogInDate;

- (id)initWithPFUser:(PFUser *)pfUser;
- (void)parseDataFromPFUser:(PFUser *)pfUser;
- (id)initWithGSUser:(GSUser *)gsUser;
- (void)parseDataFromGSUser:(GSUser *)gsUser;
- (NSString *)distanceStringToUser:(GSUser *)user;
- (NSString *)lastSeenTimeString;
- (void)updateWithPFUser:(PFUser *)pfUser block:(GSResultBlock)block;

@end
