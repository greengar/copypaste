//
//  GSMutableDictionary.m
// WhiteboardSDK
//
//  Created by Elliot Lee on 4/3/10.
//  Copyright 2013 Greengar. All rights reserved.
//

#import "GSMutableDictionary.h"
#import "WBUtils.h"

@implementation GSMutableDictionary

@synthesize delegate = _delegate;

- (id)initWithCapacity:(int)capacity {
	if ((self = [super init])) {
		keys = [[NSMutableArray alloc] initWithCapacity:capacity];
		objects = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

- (void)setObject:(id)object forKey:(id)key {
	[keys addObject:key];
	[objects addObject:object];
	
	if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(objectCountDidIncrement:)]) {
		[self.delegate objectCountDidIncrement:[objects count]];
	}
}

- (id)objectForKey:(id)key {
	int index = [keys indexOfObject:key];
	if (index == NSNotFound) {
		DLog(@"WARNING: objectForKey:%@ not found", key);
	} else {
		return [objects objectAtIndex:index];
	}
	return nil;
}

- (void)removeObjectForKey:(id)key {
	int index = [keys indexOfObject:key];
	
	if (index == NSNotFound) {
		DLog(@"WARNING: key [%@] not found", key);
	} else {
		[objects removeObjectAtIndex:index];
		[keys removeObjectAtIndex:index];
	}
}

@end
