//
//  ColorPickerImageView.h
//  ColorPicker
//
//  Created by markj on 3/6/09.
//  Copyright 2009 Mark Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SDBaseElement;

@protocol ColorPickerImageViewDelegate
- (void) colorPicked;
@end

@class GSColorCircle;

@interface ColorPickerImageView : UIImageView {
    
    NSMutableArray <ColorPickerImageViewDelegate> *pickedColorDelegateArray;
	
    GSColorCircle *circle;
	
	@private
	UIColor* color;    
	CGImageRef inImage;
	CGContextRef cgctx;
	size_t w;
	size_t h;
	CGRect rect;
	unsigned char* data;
}

@property (nonatomic, retain) id pickedColorDelegate;
@property (nonatomic, assign) SDBaseElement *holderView;

- (void) registerDelegate:(id)delegate;
- (UIColor*) getPixelColorAtLocation:(CGPoint)point;
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage;
- (void)setCircleX:(float)x y:(float)y color:(UIColor *)color;

@end
