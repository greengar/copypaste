//
//  ColorPickerView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "ColorPickerView.h"
#import "SDUtils.h"
#import "ColorPickerImageView.h"
#import "SettingManager.h"
#import "MySlider.h"
#import "PreviewArea.h"

#define kOffset                     5.0
#define kLabelIndent                5.0
#define kBrushToolsViewWidth        (frame.size.width - 2 * kOffset)
#define kSliderWidth                (kBrushToolsViewWidth - kPreviewAreaSize - kOffset * 2)
#define kLabelHeight                (20)
#define kSliderHeight               22.0
#define kMinPointSize               1.0
#define kMaxPointSize               32.0
#define kDefaultPointSize           9.0
#define kEraseButtonWidth           100.0
#define kColorSpectrum              160
#define kPreviewAreaTopMargin       9
#define kBrushToolsViewY            (kOffset + 87 + (kOffset + 70 - (460 - frame.size.height)) + 25 + 16)
#define kOpacityLabelY              (kLabelHeight + kSliderHeight - 3)
#define kTapHereHeightiPad          618
#define kBrushToolBackgroundHeight  257
#define kPreviewAreaSize       64.0

#define kScreenWidth                ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight               ([[UIScreen mainScreen] bounds].size.height)

#define SCREEN_HEIGHT           (self.view.bounds.size.height)

#define kColorPickerAnimationOffsetPortrait 634
#define kColorPickerAnimationOffsetLandscape 378

@interface ColorPickerView()
@property (nonatomic, strong) UIView *whiteArea;
@property (nonatomic, strong) UIImageView *colorPickerTitleBar;
@property (nonatomic, strong) ColorPickerImageView *colorSpectrum;
@property (nonatomic, strong) MySlider *opacitySlider;
@property (nonatomic, strong) MySlider *widthSlider;
@property (nonatomic, strong) UIView *brushToolsView;
@property (nonatomic, strong) PreviewArea *previewArea;
@end

@implementation ColorPickerView
@synthesize whiteArea = _whiteArea;
@synthesize colorSpectrum = _colorSpectrum;
@synthesize opacitySlider = _opacitySlider;
@synthesize widthSlider = _widthSlider;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBrushToolViewWithFrame:frame];
        [self initializeColorSpectrumWithFrame:frame];
    }
    return self;
}

#pragma mark - Color Spectrum
- (void) initializeColorSpectrumWithFrame:(CGRect)frame {
    self.whiteArea = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-kColorSpectrum, frame.size.width, kColorSpectrum)];
    self.whiteArea.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteArea];
    
    self.colorPickerTitleBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartDrawing.bundle/ColorPickerTitleBar.png"]];
    self.colorPickerTitleBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.colorPickerTitleBar.frame = CGRectMake(0, frame.size.height-kColorSpectrum-9, frame.size.width, 9);
    [self addSubview:self.colorPickerTitleBar];
    
    self.colorSpectrum = [[ColorPickerImageView alloc] initWithImage:[UIImage imageNamed:@"SmartDrawing.bundle/ColorSpectrumPublic.png"]];
    [self addSubview:self.colorSpectrum];
    
    [self.colorSpectrum registerDelegate:self];
    self.colorSpectrum.userInteractionEnabled = YES;
    self.colorSpectrum.frame = CGRectMake(0, frame.size.height-kColorSpectrum, frame.size.width, kColorSpectrum);
    self.colorSpectrum.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self invalidateSpectrumArea];
}

- (void)invalidateSpectrumArea {
    self.colorSpectrum.alpha = [[SettingManager sharedManager] getCurrentColorTab].opacity;
    [self.colorSpectrum setCircleX:[[SettingManager sharedManager] getCurrentColorTab].offsetXOnSpectrum
                                 y:[[SettingManager sharedManager] getCurrentColorTab].offsetYOnSpectrum
                             color:[[SettingManager sharedManager] getCurrentColorTab].tabColor];
    [self.colorSpectrum setNeedsDisplay];
}

- (void) showColorSpectrum:(BOOL)show {
    self.colorSpectrum.hidden = !show;
    self.colorPickerTitleBar.hidden = !show;
    self.whiteArea.hidden = !show;
}

- (void) colorPicked {
    [self.previewArea setNeedsDisplay];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateSelectedColor)]) {
        [self.delegate updateSelectedColor];
    }
}

#pragma mark - Brush Controls Background
- (void) initializeBrushToolViewWithFrame:(CGRect)frame {
    UIImageView *brushToolsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartDrawing.bundle/BrushToolBackground.png"]];
    brushToolsBackground.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    brushToolsBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:brushToolsBackground];
    
    self.brushToolsView = [[UIView alloc] initWithFrame:CGRectMake(kOffset, kBrushToolsViewY, frame.size.width - kOffset * 2, frame.size.height - kBrushToolsViewY)];
    self.brushToolsView.backgroundColor = [UIColor clearColor];
    self.brushToolsView.opaque = NO;
    self.brushToolsView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.brushToolsView];
    
    self.previewArea = [[PreviewArea alloc] initWithFrame:CGRectMake(0, kPreviewAreaTopMargin, kPreviewAreaSize, kPreviewAreaSize)];
    [self.brushToolsView addSubview:self.previewArea];
    
    [self initializeOpacitySliderWithFrame:frame];
    [self initializeWidthSliderWithFrame:frame];
    
    [self.previewArea setNeedsDisplay];
    [self.widthSlider setNeedsDisplay];
    [self.opacitySlider setNeedsDisplay];
}

#pragma mark - Opacity Slider
- (void)initializeOpacitySliderWithFrame:(CGRect)frame {
    UILabel *opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(kOffset + kPreviewAreaSize + kLabelIndent, kOpacityLabelY, kSliderWidth - kLabelIndent, kLabelHeight)];
    opacityLabel.font = [UIFont systemFontOfSize:15.0];
    opacityLabel.textColor = [UIColor blackColor];
    opacityLabel.shadowColor = OPAQUE_HEXCOLOR(0xE4E4E4);
    opacityLabel.text = @"Opacity:";
    opacityLabel.numberOfLines = 1;
    [opacityLabel setTextAlignment:NSTextAlignmentLeft];
    [opacityLabel setShadowOffset:CGSizeMake(0,1)];
    [opacityLabel setBackgroundColor:[UIColor clearColor]];
    
    self.opacitySlider = [[MySlider alloc] initWithFrame:CGRectMake(kOffset + kPreviewAreaSize, kOpacityLabelY + kLabelHeight - 1, kSliderWidth, kSliderHeight)];
    self.opacitySlider.backgroundColor = [UIColor clearColor];
    self.opacitySlider.minimumValue = 0.19f;
    self.opacitySlider.maximumValue = 1.0f;
    self.opacitySlider.continuous = YES;
    [self.opacitySlider addTarget:self action:@selector(opacityChanged) forControlEvents:UIControlEventValueChanged];
    [self.opacitySlider addTarget:self action:@selector(persistOpacity) forControlEvents:UIControlEventTouchUpInside];
    [self.opacitySlider setValue:kDefaultOpacity];
    self.opacitySlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.brushToolsView addSubview:opacityLabel];
    [self.brushToolsView addSubview:self.opacitySlider];
}

- (void) opacityChanged {
    if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
        return;
    }
    
    [[SettingManager sharedManager] setCurrentColorTabWithOpacity:self.opacitySlider.value];
    
    CGFloat opacity = 1.0-powf(1.0-self.opacitySlider.value, 1.0/([[SettingManager sharedManager] getCurrentColorTab].pointSize*[UIScreen mainScreen].scale));
    [[PaintingManager sharedManager] updateOpacity:opacity of:nil];
	
    [self.previewArea setNeedsDisplay];
	[self invalidateSpectrumArea];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateSelectedColor)]) {
        [self.delegate updateSelectedColor];
    }
}

- (void) invalidateOpacitySlider {
    [self.opacitySlider setValue:[[SettingManager sharedManager] getCurrentColorTab].opacity animated:NO];
}

- (void)persistOpacity {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
    [self opacityChanged];
}

#pragma mark - Width Slider
- (void) initializeWidthSliderWithFrame:(CGRect)frame {
    UILabel *widthLabel = [[UILabel alloc] initWithFrame:CGRectMake(kOffset + kPreviewAreaSize + kLabelIndent, 0, kSliderWidth - kLabelIndent, kLabelHeight)];
    widthLabel.font = [UIFont systemFontOfSize:15.0];
    widthLabel.textColor = [UIColor blackColor];
    widthLabel.shadowColor = OPAQUE_HEXCOLOR(0xE4E4E4);
    widthLabel.text = @"Width:";
    widthLabel.numberOfLines = 1;
    [widthLabel setTextAlignment:NSTextAlignmentLeft];
    [widthLabel setShadowOffset:CGSizeMake(0,1)];
    [widthLabel setBackgroundColor:[UIColor clearColor]];
    
    self.widthSlider = [[MySlider alloc] initWithFrame:CGRectMake(kOffset + kPreviewAreaSize, kLabelHeight - 1, kSliderWidth, kSliderHeight)];
    self.widthSlider.backgroundColor = [UIColor clearColor];
    self.widthSlider.minimumValue = kMinPointSize;
    self.widthSlider.maximumValue = kMaxPointSize;
    self.widthSlider.continuous = YES;
    [self.widthSlider addTarget:self action:@selector(pointSizeChanged) forControlEvents:UIControlEventValueChanged];
    [self.widthSlider addTarget:self action:@selector(persistPointSize) forControlEvents:UIControlEventTouchUpInside];
    [self.widthSlider setValue:kDefaultPointSize];
    self.widthSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.brushToolsView addSubview:widthLabel];
    [self.brushToolsView addSubview:self.widthSlider];
}

- (void) pointSizeChanged {
    [[SettingManager sharedManager] setCurrentColorTabWithPointSize:self.widthSlider.value];
    [self opacityChanged];
    [self.previewArea setNeedsDisplay];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(updateSelectedColor)]) {
        [self.delegate updateSelectedColor];
    }
}

- (void) invalidateWidthSlider {
    [self.widthSlider setValue:[[SettingManager sharedManager] getCurrentColorTab].pointSize animated:NO];
}

- (void)persistPointSize {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

#pragma mark - Color Tab call this
- (void)selectColorTabAtIndex:(int)index {
    [self invalidateSpectrumArea];
    [self invalidateOpacitySlider];
    [self invalidateWidthSlider];
    [self.previewArea setNeedsDisplay];
    
    if (index == kEraserTabIndex) {
        [self showColorSpectrum:NO];
        [self.opacitySlider setEnabled:NO];
        
    } else {
        [self showColorSpectrum:YES];
        [self.opacitySlider setEnabled:YES];
    }
}

@end
