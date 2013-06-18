//
//  ColorPickerImageView.h
//  ColorPicker
//
//  Created by markj on 3/6/09.
//  Copyright 2009 Mark Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ColorPickerImageViewDelegate
- (void)colorPicked:(UIColor *)color;
@end

@class ColorCircleView;

@interface ColorSpectrumImageView : UIImageView {
    NSMutableArray<ColorPickerImageViewDelegate> *pickedColorDelegateArray;
	
    ColorCircleView *circle;
	
	@private
	UIColor* color;    
	CGImageRef inImage;
	CGContextRef cgctx;
	size_t w;
	size_t h;
	CGRect rect;
	unsigned char* data;
}

@property (nonatomic, strong) id pickedColorDelegate;

- (void)registerDelegate:(id)delegate;
- (UIColor*)getPixelColorAtLocation:(CGPoint)point;
- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage;
- (void)setCircleX:(float)x y:(float)y color:(UIColor *)color;

@end
