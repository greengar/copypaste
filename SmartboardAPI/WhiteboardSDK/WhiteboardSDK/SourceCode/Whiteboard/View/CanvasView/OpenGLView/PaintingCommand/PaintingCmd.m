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
#import "WBBaseElement.h"

@implementation PaintingCmd
@synthesize uid = _uid;
@synthesize drawingView = _drawingView;
@synthesize layerIndex = _layerIndex;

- (id)init {
    if (self = [super init]) {
        self.uid = [WBUtils generateUniqueIdWithPrefix:@"CO_"];
    }
    return self;
}

- (void)doPaintingAction {
    
}

- (NSMutableDictionary *)saveToData {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:self.uid forKey:@"paint_cmd_uid"];
    [dict setObject:[NSNumber numberWithInt:self.layerIndex] forKey:@"paint_cmd_layer"];
    return dict;
}

- (void)loadFromData:(NSDictionary *)paintingData forElement:(WBBaseElement *)element {
    self.uid = [paintingData objectForKey:@"paint_cmd_uid"];
    self.layerIndex = [[paintingData objectForKey:@"paint_cmd_layer"] intValue];
}
@end
