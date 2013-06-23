//
//  WBMenuItem.m
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/22/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "WBMenuItem.h"

@implementation WBMenuItem

+ (id)itemInSection:(NSString *)section name:(NSString *)name progressString:(NSString *)progressString blockWithImage:(WBMenuItemBlockWithImage)block
{
    WBMenuItem *menuItem = [[WBMenuItem alloc] init];
    menuItem.section = section;
    menuItem.name = name;
    menuItem.progressString = progressString;
    menuItem.blockWithImage = block;
    return menuItem;
}

+ (id)itemInSection:(NSString *)section name:(NSString *)name progressString:(NSString *)progressString blockWithoutImage:(WBMenuItemBlockWithoutImage)block
{
    WBMenuItem *menuItem = [[WBMenuItem alloc] init];
    menuItem.section = section;
    menuItem.name = name;
    menuItem.progressString = progressString;
    menuItem.blockWithoutImage = block;
    return menuItem;
}

@end
