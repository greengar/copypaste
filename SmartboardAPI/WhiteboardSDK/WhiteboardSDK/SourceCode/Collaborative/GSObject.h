//
//  GSObject.h
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSUtils.h"

@class PFObject;

@interface GSObject : NSObject

- (id)initWithPFObject:(PFObject *)object;
- (void)loadWithPFObject:(PFObject *)object;
- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

- (void)saveInBackground;
- (void)saveInBackgroundWithBlock:(GSResultBlock)block;

- (NSString *)classname;
+ (NSString *)classname;

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSMutableArray *allKeys;

@end
