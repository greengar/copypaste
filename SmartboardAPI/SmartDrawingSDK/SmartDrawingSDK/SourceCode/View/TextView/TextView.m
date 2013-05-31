//
//  TextView.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "TextView.h"
#import "PlaceHolderTextView.h"
#import "SettingManager.h"

@interface TextView()
@property (nonatomic, strong) PlaceHolderTextView *textView;
@end

@implementation TextView
@synthesize textView = _textView;
@synthesize myFontName = _myFontName;
@synthesize myFontSize = _myFontSize;
@synthesize myColor = _myColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textView = [[PlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.textView setBackgroundColor:[UIColor clearColor]];
        [self.textView setTextColor:[UIColor darkGrayColor]];
        [self.textView setFont:[UIFont systemFontOfSize:17.0f]];
        [self.textView setDelegate:self];
        [self.textView setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self.textView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        [self.textView setPlaceHolderText:@"Enter Text"];
        
        [self updateWithFontName:[[SettingManager sharedManager] currentFontName]
                            size:[[SettingManager sharedManager] currentFontSize]];
        [self updateWithColor:[[SettingManager sharedManager] currentFontColor] x:-50 y:-50];
        
        [self addSubview:self.textView];
    }
    return self;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(elementSelected:)]) {
        [self.delegate elementSelected:self];
    }
}

- (UIView *)contentView {
    return self.textView;
}

- (void)select {
    [super select];
    [self.textView updateFrame];
    [self.textView setPlaceHolderText:@"Enter Text"];
}

- (void)deselect {
    [super deselect];
    [self.textView setPlaceHolderText:@""];
}

- (void)updateWithFontName:(NSString *)fontName size:(int)fontSize {
    self.myFontName = fontName;
    self.myFontSize = fontSize;
    [self.textView setFont:[UIFont fontWithName:fontName size:fontSize]];
    [self.textView updateFrame];
}

- (void)updateWithColor:(UIColor *)color x:(float)x y:(float)y {
    self.myColor = color;
    self.myColorLocX = x;
    self.myColorLocY = y;
    [self.textView setTextColor:color];
    [self.textView updateFrame];
}
@end
