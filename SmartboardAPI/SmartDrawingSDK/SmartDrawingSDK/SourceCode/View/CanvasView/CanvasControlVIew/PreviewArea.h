//
//  PreviewArea.h
//  SmartDrawingSDK
//
//  Created by Elliot Lee on 1/7/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingManager.h"

@interface PreviewArea : UIView<PaintingManagerDelegate>

- (CGColorRef)CGColorFromUIColor:(UIColor *)drawingColor opacity:(float)drawingOpacity;

@end
