//
//  GSObject.m
//  copypaste
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSObject.h"

@interface GSObject ()

// This does not include
// createdAt, updatedAt, authData, or objectId. It does include things like username
// and ACL.
@property (nonatomic, strong) NSMutableDictionary *innerDict;

@end

@implementation GSObject

- (id)initWithPFObject:(PFObject *)object
{
    if ((self = [super init]))
    {
        self.innerDict = [NSMutableDictionary new];
        
        for (NSString *key in [object allKeys]) {
            [self.innerDict setObject:[object objectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self.innerDict setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [self.innerDict objectForKey:key];
}

@end
