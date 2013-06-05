//
//  MultiStrokePaintingCmd.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "PaintingCmd.h"
#import "StrokePaintingCmd.h"

@interface MultiStrokePaintingCmd : PaintingCmd

@property(nonatomic, retain) NSMutableArray      * strokeArray;

@end
