//
//  WBButton.h
//  WhiteboardSDK
//
//  Created by Elliot Lee on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBButton : UIButton

@property float radius;
@property float lineWidth;
@property BOOL noGradient;
@property (nonatomic, retain) UIColor*  fillColor;
@property (nonatomic, retain) UIColor*  strokeColor;
@property (nonatomic, retain) UIColor*  tapColor;
@property (nonatomic, retain) UIColor*  tapStrokeColor;

@end
