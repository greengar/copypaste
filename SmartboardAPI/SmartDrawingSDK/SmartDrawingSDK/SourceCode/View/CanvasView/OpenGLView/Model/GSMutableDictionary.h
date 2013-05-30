//
//  GSMutableDictionary.h
// SmartDrawingSDK
//
//  Created by Elliot Lee on 4/3/10.
//  Copyright 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSMutableDictionaryDelegate

// Allows us to act on 2-finger touch
- (void)objectCountDidIncrement:(NSUInteger)newCount;

@end


@interface GSMutableDictionary : NSObject {
	NSMutableArray *keys;
	NSMutableArray *objects;
}

@property (nonatomic, assign) id<GSMutableDictionaryDelegate> delegate;

- (id)initWithCapacity:(int)capacity;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

@end
