//
//  FontColorPickerView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/31/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "FontColorPickerView.h"
#import "SettingManager.h"
#import "WBUtils.h"
#import "GSButton.h"
#import "HistoryManager.h"

@interface FontColorPickerView()
@property (nonatomic, strong) ColorPickerImageView *colorPickerImageView;
@end

@implementation FontColorPickerView
@synthesize colorPickerImageView = _colorPickerImageView;
@synthesize currentTextView = _currentTextView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = OPAQUE_HEXCOLOR_FILL(0x0c0d14);
        
        self.colorPickerImageView = [[ColorPickerImageView alloc] initWithImage:[UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPublic.png"]];
        [self.colorPickerImageView setFrame:CGRectMake(0, 0, frame.size.width, kColorSpectrum)];
        [self.colorPickerImageView setUserInteractionEnabled:YES];
        [self addSubview:self.colorPickerImageView];
        
    }
    return self;
}

- (void)setCurrentTextView:(TextElement *)currentTextView {
    _currentTextView = currentTextView;
    [self.colorPickerImageView setHolderView:_currentTextView];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        if (self.currentTextView) {
            [self.colorPickerImageView setCircleX:self.currentTextView.myColorLocX
                                                y:self.currentTextView.myColorLocY
                                            color:self.currentTextView.myColor];
            [self.colorPickerImageView setNeedsDisplay];
        }
    }
}

- (void)doneSelectColor {
    [self setHidden:YES];
}

@end
