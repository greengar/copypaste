//
//  FontColorPickerView.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/31/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "FontColorPickerView.h"
#import "SettingManager.h"
#import "SDUtils.h"
#import "GSButton.h"

@interface FontColorPickerView()
@property (nonatomic, strong) ColorPickerImageView *colorPickerImageView;
@property (nonatomic, strong) UILabel *fontPreviewLabel;
@end

@implementation FontColorPickerView
@synthesize colorPickerImageView = _colorPickerImageView;
@synthesize fontPreviewLabel = _fontPreviewLabel;
@synthesize currentTextView = _currentTextView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.colorPickerImageView = [[ColorPickerImageView alloc] initWithImage:[UIImage imageNamed:@"SmartDrawing.bundle/ColorSpectrumPublic.png"]];
        [self.colorPickerImageView setFrame:CGRectMake(0, 0, frame.size.width, kColorSpectrum)];
        [self.colorPickerImageView registerDelegate:self];
        [self.colorPickerImageView setUserInteractionEnabled:YES];
        [self addSubview:self.colorPickerImageView];
        
        self.fontPreviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kColorSpectrum, frame.size.width, frame.size.height-kColorSpectrum-kButtonHeight)];
        [self.fontPreviewLabel setBackgroundColor:[UIColor clearColor]];
        [self.fontPreviewLabel setTextAlignment:NSTextAlignmentCenter];
        [self.fontPreviewLabel setText:@"Font Preview"];
        [self addSubview:self.fontPreviewLabel];
        
        [self updateColor];
        
        GSButton *doneButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneSelectColor) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setFrame:CGRectMake(0, frame.size.height-kButtonHeight, frame.size.width/5, kButtonHeight)];
        [self addSubview:doneButton];
    }
    return self;
}

- (void)setCurrentTextView:(TextView *)currentTextView {
    _currentTextView = currentTextView;
    [self.colorPickerImageView setHolderView:_currentTextView];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        if (self.currentTextView) {
            [self.fontPreviewLabel setFont:[UIFont fontWithName:[self.currentTextView myFontName]
                                                           size:[self.currentTextView myFontSize]]];
            [self.fontPreviewLabel setTextColor:[self.currentTextView myColor]];
        }
    }
}

- (void)doneSelectColor {
    [self setHidden:YES];
}

- (void)colorPicked {
    [self updateColor];
}

- (void)updateColor {
    if (self.currentTextView) {
        [self.currentTextView updateWithColor:[[SettingManager sharedManager] currentFontColor] x:-50 y:-50];
    }
    
    [self.fontPreviewLabel setTextColor:[[SettingManager sharedManager] currentFontColor]];
}

@end
