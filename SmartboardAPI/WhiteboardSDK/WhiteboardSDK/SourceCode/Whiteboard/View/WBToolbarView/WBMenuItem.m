//
//  WBMenuItem.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/22/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBMenuItem.h"

@implementation WBMenuItem

+ (id)itemWithSection:(NSString *)section name:(NSString *)name progressString:(NSString *)progressString usingBlock:(WBMenuItemBlock)block
{
    WBMenuItem *menuItem = [[WBMenuItem alloc] init];
    menuItem.section = section;
    menuItem.name = name;
    menuItem.progressString = progressString;
    menuItem.block = block;
    return menuItem;
}

@end
