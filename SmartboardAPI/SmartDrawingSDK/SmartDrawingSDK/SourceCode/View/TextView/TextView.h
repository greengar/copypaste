//
//  TextView.h
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "SDBaseView.h"

@interface TextView : SDBaseView <UITextViewDelegate>

@property (nonatomic, strong) NSString  *myFontName;
@property (nonatomic)         int        myFontSize;
@property (nonatomic, strong) UIColor   *myColor;

- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize;
- (void)updateWithColor:(UIColor *)color;

@end
