//
//  GSSParseQueryHelper.h
//  copypaste
//
//  Created by Hector Zhao on 4/19/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GSSParseQueryHelper : NSObject

+ (void)setAdminRoleForUser:(PFUser *)user;
+ (void)removeAdminRoleFromUser:(PFUser *)user;
+ (void)updateCurrentUserLocation;
+ (PFGeoPoint *)getCurrentUserLocation;
//+ (void)getAllUser;

@end
