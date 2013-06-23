//
//  MultiStrokePaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "MultiStrokePaintingCmd.h"

@implementation MultiStrokePaintingCmd
@synthesize strokeArray = _strokeArray;

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super initWithDict:dict]) {
        self.strokeArray = [NSMutableArray new];
        NSArray *strokeDicts = [dict objectForKey:@"paint_multi_stroke_array"];
        for (int i = 0; i < [strokeDicts count]; i++) {
            NSDictionary *strokeDict = [strokeDicts objectAtIndex:i];
            StrokePaintingCmd *cmd = (StrokePaintingCmd *) [StrokePaintingCmd loadFromDict:strokeDict];
            [self.strokeArray addObject:cmd];
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.strokeArray = [NSMutableArray new];
    }
    return self;
}

- (void)doPaintingAction {
    for (int i = 0; i < [self.strokeArray count]; i++) {
        StrokePaintingCmd *cmd = [self.strokeArray objectAtIndex:i];
        [cmd doPaintingAction];
    }
}

- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super saveToDict]];
    [dict setObject:@"MultiStrokePaintingCmd" forKey:@"paint_cmd_type"];
    
    if ([self.strokeArray count]) {
        NSMutableDictionary *strokeDicts = [NSMutableDictionary dictionaryWithCapacity:[self.strokeArray count]];
        for (int i = 0; i < [self.strokeArray count]; i++) {
            StrokePaintingCmd *cmd = [self.strokeArray objectAtIndex:i];
            [strokeDicts setObject:[cmd saveToDict] forKey:cmd.uid];
        }
        [dict setObject:strokeDicts forKey:@"paint_multi_stroke_array"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (PaintingCmd *)loadFromDict:(NSDictionary *)dict {
    MultiStrokePaintingCmd *strokePaintCmd = [[MultiStrokePaintingCmd alloc] initWithDict:dict];
    return strokePaintCmd;
}

@end
