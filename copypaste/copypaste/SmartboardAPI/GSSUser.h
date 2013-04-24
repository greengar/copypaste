//
//  GSSUser.h
//  copypaste
//
//  Created by Hector Zhao on 4/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class GSSUser;

@protocol GSSUser
+ (GSSUser *)userInfoFromDictionary:(NSDictionary *)userInfo;
@end

@interface GSSUser : NSObject <GSSUser, NSCoding>

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

- (id)initWithPFUser:(PFUser *)pfUser;
- (void)parseDataFromPFUser:(PFUser *)pfUser;
- (NSString *)distanceStringToUser:(GSSUser *)user;

@end
