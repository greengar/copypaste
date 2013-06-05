//
//  TextElement.h
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDBaseElement.h"

@interface TextElement : SDBaseElement <UITextViewDelegate>

@property (nonatomic, strong) NSString  *myFontName;
@property (nonatomic)         int        myFontSize;
@property (nonatomic, strong) UIColor   *myColor;
@property (nonatomic)         float      myColorLocX;
@property (nonatomic)         float      myColorLocY;

- (void)setText:(NSString *)text;
- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize;
- (void)updateWithColor:(UIColor *)color x:(float)x y:(float)y;

@end
