//
//  PaintingCmd.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "PaintingCmd.h"
#import "ClearPaintingCmd.h"
#import "ImagePaintingCmd.h"
#import "StrokePaintingCmd.h"
#import "MultiStrokePaintingCmd.h"
#import "WBUtils.h"

@implementation PaintingCmd
@synthesize uid = _uid;
@synthesize drawingView = _drawingView;
@synthesize layerIndex = _layerIndex;

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.uid = [dict objectForKey:@"paint_cmd_uid"];
        self.layerIndex = [[dict objectForKey:@"paint_cmd_layer"] intValue];
    }
    return self;
}
- (id)init {
    if (self = [super init]) {
        self.uid = [WBUtils stringFromDate:[NSDate date]];
    }
    return self;
}

- (void)doPaintingAction {
    
}

- (NSDictionary *)saveToDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"paint_cmd_uid"];
    [dict setObject:[NSNumber numberWithInt:self.layerIndex] forKey:@"paint_cmd_layer"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (PaintingCmd *)loadFromDict:(NSDictionary *)dict {
    PaintingCmd *paintCmd = nil;
    NSString *paintCmdType = [dict objectForKey:@"paint_cmd_type"];
    if ([paintCmdType isEqualToString:@"ClearPaintingCmd"]) {
        paintCmd = [ClearPaintingCmd loadFromDict:dict];
    } else if ([paintCmdType isEqualToString:@"ImagePaintingCmd"]) {
        paintCmd = [ImagePaintingCmd loadFromDict:dict];
    } else if ([paintCmdType isEqualToString:@"StrokePaintingCmd"]) {
        paintCmd = [StrokePaintingCmd loadFromDict:dict];
    } else if ([paintCmdType isEqualToString:@"MultiStrokePaintingCmd"]) {
        paintCmd = [MultiStrokePaintingCmd loadFromDict:dict];
    }
    return paintCmd;
}

@end
