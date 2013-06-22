//
//  WBMenuItem.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/22/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WBCompletionBlock)(NSString *message);
typedef void (^WBMenuItemBlock)(UIImage *image, WBCompletionBlock completionBlock);

@interface WBMenuItem : NSObject

@property (copy) NSString *section;
@property (copy) NSString *name;
@property (copy) NSString *progressString;
@property (strong) WBMenuItemBlock block;

+ (id)itemWithSection:(NSString *)section name:(NSString *)name progressString:(NSString *)progressString usingBlock:(WBMenuItemBlock)block;

@end
