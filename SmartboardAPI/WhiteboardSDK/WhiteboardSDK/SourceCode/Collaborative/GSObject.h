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
- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@property (nonatomic, strong) NSString *uid;

@end
