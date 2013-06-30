//
//  StrokePaintingCmd.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "PaintingCmd.h"

@interface StrokePaintingCmd : PaintingCmd {
    CGPoint               startPoint;
    CGPoint               endPoint;
    CGFloat               pointSize;
    CGFloat               components[4];
}

- (void)strokeFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (void)pointSizeWithSize:(CGFloat)size;
- (void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (void)doPaintingAction;

@end
