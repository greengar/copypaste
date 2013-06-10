//
//  GSSUser.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GSUtils.h"

@class GSUser;
@class PFGeoPoint;
@class PFUser;

@protocol GSUser
+ (GSUser *)userInfoFromDictionary:(NSDictionary *)userInfo;
@end

@interface GSUser : NSObject <GSUser, NSCoding>

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
@property (nonatomic)         BOOL isFacebookUser;
@property (nonatomic, retain) NSString *facebookId;
@property (nonatomic, retain) NSString *facebookScreenName;
@property (nonatomic)         BOOL isOnline;

- (id)initWithPFUser:(PFUser *)pfUser;
- (id)initWithPFUser:(PFUser *)pfUser cacheAvatar:(BOOL)cache;
- (void)parseDataFromPFUser:(PFUser *)pfUser;
- (void)parseDataFromPFUser:(PFUser *)pfUser cacheAvatar:(BOOL)cache;
- (void)cacheAvatar;
- (id)initWithGSUser:(GSUser *)pfUser;
- (id)initWithGSUser:(GSUser *)gsUser cacheAvatar:(BOOL)cache;
- (void)parseDataFromGSUser:(GSUser *)gsUser;
- (void)parseDataFromGSUser:(GSUser *)gsUser cacheAvatar:(BOOL)cache;
- (NSString *)displayName;
- (NSString *)distanceStringToUser:(GSUser *)user;
- (NSString *)lastSeenTimeString;
- (void)updateWithPFUser:(PFUser *)pfUser block:(GSResultBlock)block;

@end
