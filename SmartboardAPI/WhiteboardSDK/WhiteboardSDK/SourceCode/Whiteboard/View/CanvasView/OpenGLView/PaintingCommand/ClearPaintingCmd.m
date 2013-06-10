//
//  ClearPaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "ClearPaintingCmd.h"

@implementation ClearPaintingCmd

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super initWithDict:dict]) {
    }
    return self;
}

- (void)doPaintingAction {
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"ClearPaintingCmd" forKey:@"paint_cmd_type"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (PaintingCmd *)loadFromDict:(NSDictionary *)dict {
    ClearPaintingCmd *clearPaintCmd = [[ClearPaintingCmd alloc] initWithDict:dict];
    return clearPaintCmd;
}

@end
