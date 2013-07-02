//
//  ImagePaintingCmd.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingCmd.h"

@interface ImagePaintingCmd : PaintingCmd {
    CGImageRef image;
}

- (void)setCGIImage:(CGImageRef)img;

@end
