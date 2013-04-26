//
//  GSSParseQueryHelper.m
//  copypaste
//
//  Created by Hector Zhao on 4/19/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSParseQueryHelper.h"

@implementation GSParseQueryHelper

+ (void)setAdminRoleForUser:(PFUser *)user {
    // Make a new role for administrators
    PFACL *roleACL = [PFACL ACL];
    [roleACL setPublicReadAccess:YES];
    [roleACL setPublicWriteAccess:YES];
    [user setACL:roleACL];
    [user saveInBackground];
}

+ (void)removeAdminRoleFromUser:(PFUser *)user {
    PFACL *roleACL = [PFACL ACL];
    [roleACL setPublicReadAccess:NO];
    [roleACL setPublicWriteAccess:NO];
    [user setACL:roleACL];
    [user saveInBackground];
}

+ (void) updateCurrentUserLocation {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFGeoPoint *userGeoPoint = [[PFUser currentUser] objectForKey:@"location"];
                DLog(@"Geo: %@", userGeoPoint);
            }
        }];
    }];
}

+ (PFGeoPoint *)getCurrentUserLocation {
    return [[PFUser currentUser] objectForKey:@"location"];
}

//+ (void)getAllUser {
//    PFQuery *appIdQuery = [PFQuery queryWithClassName:@"App"];
//    static NSString *desiredAppIdString = nil;
//    static PFObject *desiredAppIdObject = nil;
//    [appIdQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (PFObject *object in objects) {
//            DLog(@"object: %@", object);
//            if ([[object objectForKey:@"app_name"] isEqualToString:@"Smartboard"]) {
//                desiredAppIdString = [object objectId];
//                desiredAppIdObject = object;
//            }
//        }
//        DLog(@"App Id: %@", desiredAppIdString);
//        
//        PFQuery *query = [PFUser query];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                // The find succeeded. The first 100 objects are available in objects
//                for (PFUser *user in objects) {
//                    [GSSParseQueryHelper setAdminRoleForUser:user];
//                    DLog(@"User: %@", user.username);
//                    PFRelation *relation = [user relationforKey:@"initial_app_id"];
//                    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                        DLog(@"Relation: %@ %@", user.username, objects);
//                    }];
//                    [GSSParseQueryHelper removeAdminRoleFromUser:user];
//                }
//            } else {
//                // Log details of the failure
//                DLog(@"Error: %@ %@", error, [error userInfo]);
//            }
//        }];
//    }];
//}

@end
