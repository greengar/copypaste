//
//  FontPickerView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/30/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "FontPickerView.h"
#import "WBUtils.h"
#import "SettingManager.h"
#import "GSButton.h"
#import "HistoryManager.h"

#define kPickerDefaultHeight 216
#define kFontNameIndex 0
#define kFontSizeIndex kFontNameIndex+1

@interface FontPickerView()
@property (nonatomic, strong) UIPickerView *fontPickerView;
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
        
        self.backgroundColor = OPAQUE_HEXCOLOR_FILL(0x0c0d14);
        
        self.fontNames = [NSArray arrayWithObjects:FONTS_AVAILABLE_ON_ALL_DEVICES];
        self.fontSizes = [NSArray arrayWithObjects:FONT_SIZES];
        
        self.fontPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             frame.size.width,
                                                                             kPickerDefaultHeight)];
        [self.fontPickerView setDelegate:self];
        [self.fontPickerView setShowsSelectionIndicator:YES];
        [self.fontPickerView selectRow:[self selectedName:[[SettingManager sharedManager] currentFontName]]
                           inComponent:kFontNameIndex animated:YES];
        [self.fontPickerView selectRow:[self selectedSize:[[SettingManager sharedManager] currentFontSize]]
                           inComponent:kFontSizeIndex animated:YES];
        [self addSubview:self.fontPickerView];
    }
    return self;
}

- (void)setCurrentTextView:(TextElement *)currentTextView {
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
}

- (void)updateCurrentTextView {
    if (self.currentTextView) {
        [self.currentTextView updateWithFontName:[[SettingManager sharedManager] currentFontName]
                                            size:[[SettingManager sharedManager] currentFontSize]];
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
