//
//  FontColorPickerView.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/31/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextElement.h"
#import "ColorPickerImageView.h"

@interface FontColorPickerView : UIView <ColorPickerImageViewDelegate>

@property (nonatomic, assign) TextElement *currentTextView;

@end
