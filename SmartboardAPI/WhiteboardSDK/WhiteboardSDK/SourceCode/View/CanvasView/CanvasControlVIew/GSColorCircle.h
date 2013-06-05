//
//  GSColorCircle.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 4/15/11.
//  Copyright 2013 Greengar. All rights reserved.
//  Use to draw a Color Tab, please do not modify
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GSColorCircle : UIView

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)nColor andOpacity:(float)newOpacity andPointSize:(float)newPointSize;

@property (nonatomic, strong)   UIColor * circleColor;
@property (nonatomic)           float     circleOpacity;
@property (nonatomic)           float     circlePointSize;

@end
