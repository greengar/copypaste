//
//  GSObject.m
//  copypaste
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSObject.h"

@interface GSObject ()

@property (nonatomic, strong) NSMutableDictionary *d;

@end

@implementation GSObject

- (id)initWithPFObject:(PFObject *)object
{
    if ((self = [super init]))
    {
        self.d = [NSMutableDictionary new];
        // This does not include
        // createdAt, updatedAt, authData, or objectId. It does include things like username
        // and ACL.
        for (NSString *key in [object allKeys]) {
            [self.d setObject:[object objectForKey:key] forKey:key];
        }
    }
    return self;
}

@end
