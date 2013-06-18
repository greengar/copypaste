//
//  WBColorPickerView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 6/17/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBToolMonitorView.h"
#import "WBUtils.h"
#import "SettingManager.h"
#import "WBEraserButton.h"
#import <QuartzCore/QuartzCore.h>

#define kCanvasMonitorTag   777
#define kOpacitySliderTag   kCanvasMonitorTag+1
#define kWidthSliderTag     kCanvasMonitorTag+2
#define kPreviewAreaTag     kCanvasMonitorTag+3

@interface WBToolMonitorView()
{
    WBEraserButton *eraserButton;
}
@property (nonatomic, strong) ColorSpectrumImageView *colorSpectrumImageView;

@end

@implementation WBToolMonitorView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        
        UIImage *colorSpectrumImage = [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPublic.png"];
        self.colorSpectrumImageView = [[ColorSpectrumImageView alloc] initWithImage:colorSpectrumImage];
        [self.colorSpectrumImageView setFrame:CGRectMake(0, 0, colorSpectrumImage.size.width, colorSpectrumImage.size.height)];
        [self.colorSpectrumImageView setUserInteractionEnabled:YES];
        [self.colorSpectrumImageView registerDelegate:self];
        [self addSubview:self.colorSpectrumImageView];
        
        UIView *canvasMonitorView = [[UIView alloc] initWithFrame:CGRectMake(colorSpectrumImage.size.width, 0,
                                                                             frame.size.width-colorSpectrumImage.size.width,
                                                                             colorSpectrumImage.size.height)];
        [canvasMonitorView setBackgroundColor:[UIColor clearColor]];
        [canvasMonitorView setTag:kCanvasMonitorTag];
        [self addSubview:canvasMonitorView];
        
        float sliderLeftMargin = 10;
        float sliderWidth = frame.size.width-colorSpectrumImage.size.width-2*sliderLeftMargin;
        CustomSlider *opacitySlider = [[CustomSlider alloc] initWithFrame:CGRectMake(sliderLeftMargin,
                                                                                     colorSpectrumImage.size.height-40,
                                                                                     sliderWidth,
                                                                                     20)];
        opacitySlider.backgroundColor = [UIColor clearColor];
        opacitySlider.minimumValue = 0.19f;
        opacitySlider.maximumValue = 1.0f;
        opacitySlider.continuous = YES;
        opacitySlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        opacitySlider.tag = kOpacitySliderTag;
        opacitySlider.value = [[SettingManager sharedManager] getCurrentColorTab].opacity;
        [opacitySlider setMinimumTitle:@"0%"];
        [opacitySlider setMaximumTitle:@"100%"];
        [opacitySlider addTarget:self action:@selector(opacityChanged:) forControlEvents:UIControlEventValueChanged];
        [opacitySlider addTarget:self action:@selector(persistOpacity) forControlEvents:UIControlEventTouchUpInside];
        [canvasMonitorView addSubview:opacitySlider];
        
        CustomSlider *widthSlider = [[CustomSlider alloc] initWithFrame:CGRectMake(sliderLeftMargin,
                                                                                   colorSpectrumImage.size.height-80,
                                                                                   sliderWidth,
                                                                                   20)];
        widthSlider.backgroundColor = [UIColor clearColor];
        widthSlider.minimumValue = kMinPointSize;
        widthSlider.maximumValue = kMaxPointSize;
        widthSlider.continuous = YES;
        widthSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        widthSlider.tag = kWidthSliderTag;
        widthSlider.value = [[SettingManager sharedManager] getCurrentColorTab].pointSize;
        [widthSlider setMinimumTitle:@"-"];
        [widthSlider setMaximumTitle:@"+"];
        [widthSlider addTarget:self action:@selector(pointSizeChanged:) forControlEvents:UIControlEventValueChanged];
        [widthSlider addTarget:self action:@selector(persistPointSize) forControlEvents:UIControlEventTouchUpInside];
        [canvasMonitorView addSubview:widthSlider];
        
        float previewWidth = sliderWidth*2.5/4;
        float previewTopMargin = 20;
        float previewHeight = 80;
        ColorPreviewView *previewArea = [[ColorPreviewView alloc] initWithFrame:CGRectMake(sliderLeftMargin, previewTopMargin,
                                                                              previewWidth, previewHeight)];
        [previewArea setTag:kPreviewAreaTag];
        [self.colorSpectrumImageView registerDelegate:previewArea];
        [canvasMonitorView addSubview:previewArea];
        
        eraserButton = [[WBEraserButton alloc] init];
        eraserButton.frame = CGRectMake(82, previewTopMargin+2, [eraserButton preferredSize].width, [eraserButton preferredSize].height);
        [eraserButton addTarget:self action:@selector(switchToEraser:) forControlEvents:UIControlEventTouchDown];
        [eraserButton setSelected:([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex)];
        [canvasMonitorView addSubview:eraserButton];
        
        float closeButtonSize = 44;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton.titleLabel setFont:[UIFont systemFontOfSize:36.0f]];
        [closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [closeButton setTitle:@"x" forState:UIControlStateNormal];
        [closeButton setFrame:CGRectMake(frame.size.width-closeButtonSize, 0, closeButtonSize, closeButtonSize)];
        [closeButton addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchDown];
        [self addSubview:closeButton];
    }
    return self;
}

#pragma mark - Update UI
- (void)invalidateOpacitySlider {
    [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kOpacitySliderTag]) setValue:[[SettingManager sharedManager] getCurrentColorTab].opacity animated:NO];
}

- (void)invalidatePreviewArea {
    [[[self viewWithTag:kCanvasMonitorTag] viewWithTag:kPreviewAreaTag] setNeedsDisplay];
}

- (void)invalidateWidthSlider {
    [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kWidthSliderTag]) setValue:[[SettingManager sharedManager] getCurrentColorTab].pointSize animated:NO];
}

- (void)enableEraser:(BOOL)enable {
    if (enable) {
        eraserButton.selected = YES;
        [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kOpacitySliderTag]) setEnabled:NO];
        [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kOpacitySliderTag]) setValue:1.0f animated:NO];
    } else {
        eraserButton.selected = NO;
        [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kOpacitySliderTag]) setEnabled:YES];
        [self invalidateOpacitySlider];
    }
    [self invalidatePreviewArea];
    [self invalidateWidthSlider];
}

#pragma mark - Persist
- (void)persistOpacity {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

- (void)persistPointSize {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

#pragma mark - Delegate
- (void)pointSizeChanged:(CustomSlider *)widthSlider {
    [[SettingManager sharedManager] setCurrentColorTabWithPointSize:widthSlider.value];
    [self invalidatePreviewArea];
    [self.colorSpectrumImageView setNeedsDisplay];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pointSizeChanged:)]) {
        [self.delegate pointSizeChanged:widthSlider.value];
    }
}

- (void)opacityChanged:(CustomSlider *)opacitySlider {
    [[SettingManager sharedManager] setCurrentColorTabWithOpacity:opacitySlider.value];
    [self invalidatePreviewArea];
    [self.colorSpectrumImageView setNeedsDisplay];
	
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(opacityChanged:)]) {
        [self.delegate opacityChanged:opacitySlider.value];
    }
}

- (void)switchToEraser:(UIButton *)button {
    [[SettingManager sharedManager] setCurrentColorTab:kEraserTabIndex];
    [self enableEraser:YES];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectEraser:)]) {
        [self.delegate selectEraser:YES];
    }
}

- (void)closeMe {
    [self removeFromSuperview];
    [[SettingManager sharedManager] persistColorTabSetting];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(monitorClosed)]) {
        [self.delegate monitorClosed];
    }
}

- (void)colorPicked:(UIColor *)color {
    [self enableEraser:NO];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(colorPicked:)]) {
        [self.delegate colorPicked:color];
    }
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectEraser:)]) {
        [self.delegate selectEraser:NO];
    }
}

- (void)wantToPickColorWhenEraserIsActivated {
    [[SettingManager sharedManager] setCurrentColorTab:0];
}

@end
