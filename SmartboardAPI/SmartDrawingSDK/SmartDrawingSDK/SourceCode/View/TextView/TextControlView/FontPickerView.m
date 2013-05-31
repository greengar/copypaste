//
//  FontPickerView.m
//  TestSDSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "FontPickerView.h"
#import "SDUtils.h"
#import "SettingManager.h"
#import "GSButton.h"

#define kPickerDefaultHeight 216
#define kFontNameIndex 0
#define kFontSizeIndex kFontNameIndex+1

@interface FontPickerView()
@property (nonatomic, strong) UIPickerView *fontPickerView;
@property (nonatomic, strong) UILabel *fontPreviewLabel;
@property (nonatomic, strong) NSArray *fontNames;
@property (nonatomic, strong) NSArray *fontSizes;
@end

@implementation FontPickerView
@synthesize currentTextView = _currentTextView;
@synthesize fontPickerView = _fontPickerView;
@synthesize fontNames = _fontNames;
@synthesize fontSizes = _fontSizes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.fontNames = [NSArray arrayWithObjects:FONTS_AVAILABLE_ON_ALL_DEVICES];
        self.fontSizes = [NSArray arrayWithObjects:FONT_SIZES];
        
        self.fontPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kPickerDefaultHeight)];
        [self.fontPickerView setDelegate:self];
        [self.fontPickerView setShowsSelectionIndicator:YES];
        [self.fontPickerView selectRow:[self selectedName:[[SettingManager sharedManager] currentFontName]]
                           inComponent:kFontNameIndex animated:YES];
        [self.fontPickerView selectRow:[self selectedSize:[[SettingManager sharedManager] currentFontSize]]
                           inComponent:kFontSizeIndex animated:YES];
        [self addSubview:self.fontPickerView];
        
        self.fontPreviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kPickerDefaultHeight, frame.size.width, frame.size.height-kPickerDefaultHeight-kButtonHeight)];
        [self.fontPreviewLabel setBackgroundColor:[UIColor clearColor]];
        [self.fontPreviewLabel setTextAlignment:NSTextAlignmentCenter];
        [self.fontPreviewLabel setText:@"Font Preview"];
        [self addSubview:self.fontPreviewLabel];
        
        [self updatePreview];
        
        GSButton *doneButton = [GSButton buttonWithType:UIButtonTypeCustom themeStyle:GreenButtonStyle];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneSelectFont) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setFrame:CGRectMake(0, frame.size.height-kButtonHeight, frame.size.width/5, kButtonHeight)];
        [self addSubview:doneButton];
    }
    return self;
}

- (void)setCurrentTextView:(TextView *)currentTextView {
    _currentTextView = currentTextView;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [[SettingManager sharedManager] persistTextSetting];
    } else {
        if (self.currentTextView) {
            [self.fontPickerView selectRow:[self selectedName:[self.currentTextView myFontName]]
                               inComponent:kFontNameIndex animated:YES];
            [self.fontPickerView selectRow:[self selectedSize:[self.currentTextView myFontSize]]
                               inComponent:kFontSizeIndex animated:YES];
        }
        [self updatePreview];
    }
}

- (void)doneSelectFont {
    [self setHidden:YES];
}

#pragma mark - Picker View Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return (component == kFontNameIndex) ? pickerView.frame.size.width*3/4 : pickerView.frame.size.width/4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return (component == kFontNameIndex) ? [self.fontNames count] : [self.fontSizes count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return (component == kFontNameIndex) ? [self.fontNames objectAtIndex:row] :
	[NSString stringWithFormat:@"%dpt",[[self.fontSizes objectAtIndex:row] intValue]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if(component == kFontNameIndex) {
		[SettingManager sharedManager].currentFontName = [self.fontNames objectAtIndex:row];
	} else {
		[SettingManager sharedManager].currentFontSize = [[self.fontSizes objectAtIndex:row] intValue];
	}
    [self updateCurrentTextView];
    [self updatePreview];
}

- (void)updateCurrentTextView {
    if (self.currentTextView) {
        [self.currentTextView updateWithFontName:[[SettingManager sharedManager] currentFontName]
                                            size:[[SettingManager sharedManager] currentFontSize]];
    }
}

- (void)updatePreview {
    if (self.currentTextView) {
        [self.fontPreviewLabel setFont:[UIFont fontWithName:self.currentTextView.myFontName
                                                       size:self.currentTextView.myFontSize]];
        [self.fontPreviewLabel setTextColor:self.currentTextView.myColor];
    } else {
        [self.fontPreviewLabel setFont:[UIFont fontWithName:[[SettingManager sharedManager] currentFontName]
                                                       size:[[SettingManager sharedManager] currentFontSize]]];
        [self.fontPreviewLabel setTextColor:[[SettingManager sharedManager] currentFontColor]];
    }
}

- (int)selectedSize:(int)size_ {
    int index = -1;
    for (int i = 0; i < [self.fontSizes count]; i++) {
        NSNumber *size = [self.fontSizes objectAtIndex:i];
        if ([size intValue] == size_) {
            index = i;
            break;
        }
    }
    return (index >= 0) ? index : 0;
}

- (int)selectedName:(NSString *)name_ {
    int index = -1;
    for (int i = 0; i < [self.fontNames count]; i++) {
        NSString *name = [self.fontNames objectAtIndex:i];
        if ([name isEqualToString:name_]) {
            index = i;
            break;
        }
    }
    return (index >= 0) ? index : 0;
}

@end
