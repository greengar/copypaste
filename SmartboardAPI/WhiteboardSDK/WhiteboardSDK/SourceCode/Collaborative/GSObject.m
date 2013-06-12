//
//  GSObject.m
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/25/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSObject.h"
#import <Parse/Parse.h>
#import "GSSession.h"

@interface GSObject ()
// This does not include createdAt, updatedAt, authData, or objectId.
// It does include things like username and ACL.
@property (nonatomic, strong) NSMutableDictionary *innerDict;
@end

@implementation GSObject
@synthesize uid = _uid;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;
@synthesize innerDict = _innerDict;
@synthesize allKeys = _allKeys;

- (id)init {
    if (self = [super init]) {
        PFObject *object = [PFObject objectWithClassName:NSStringFromClass([self class])];
        [self loadWithPFObject:object];
    }
    return self;
}

- (id)initWithPFObject:(PFObject *)object {
    if ((self = [super init])) {
        self.uid = [object objectId];
        self.createdAt = [object createdAt];
        self.updatedAt = [object updatedAt];
        self.innerDict = [NSMutableDictionary new];
        self.allKeys = [NSMutableArray arrayWithArray:[object allKeys]];
        
        for (NSString *key in [object allKeys]) {
            [self.innerDict setObject:[object objectForKey:key] forKey:key];
        }
    }
    return self;
}

- (void)loadWithPFObject:(PFObject *)object {
    self.uid = [object objectId];
    self.createdAt = [object createdAt];
    self.updatedAt = [object updatedAt];
    self.innerDict = [NSMutableDictionary new];
    self.allKeys = [NSMutableArray arrayWithArray:[object allKeys]];
    
    for (NSString *key in [object allKeys]) {
        [self.innerDict setObject:[object objectForKey:key] forKey:key];
    }
}

- (void)setObject:(id)object forKey:(NSString *)key {
    if (object && key) {
        BOOL keyExisted = NO;
        for (NSString *existedKey in self.allKeys) {
            if ([key isEqualToString:existedKey]) {
                keyExisted = YES;
            }
        }
        if (!keyExisted) {
            [self.allKeys addObject:key];
        }
        [self.innerDict setObject:object forKey:key];
    }
}

- (id)objectForKey:(NSString *)key {
    return [self.innerDict objectForKey:key];
}

- (void)saveInBackground {
    PFObject *object = [PFObject objectWithClassName:NSStringFromClass([self class])];
    for (NSString *key in self.allKeys) {
        [object setObject:[self objectForKey:key] forKey:key];
    }
    [object saveInBackground];
}

- (void)saveInBackgroundWithBlock:(GSResultBlock)block {
    PFObject *object = [PFObject objectWithClassName:NSStringFromClass([self class])];
    for (NSString *key in self.allKeys) {
        [object setObject:[self objectForKey:key] forKey:key];
    }
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (block) {
            block(succeeded, error);
        }
    }];
}

@end
