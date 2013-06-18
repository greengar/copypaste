//
//  PreviewArea.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 1/7/09.
//  Copyright 2009 GreenGar Studios <http://www.greengar.com/>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorSpectrumImageView.h"

@interface ColorPreviewView : UIView <ColorPickerImageViewDelegate>

- (CGColorRef)CGColorFromUIColor:(UIColor *)drawingColor opacity:(float)drawingOpacity;

@end
