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
@property (nonatomic, strong) ColorPreviewView *previewArea;

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
        
        [[SettingManager sharedManager] setCurrentColorTab:0];
        
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
        [widthSlider addTarget:self action:@selector(pointSizeChanged:) forControlEvents:UIControlEventValueChanged];
        [widthSlider addTarget:self action:@selector(persistPointSize) forControlEvents:UIControlEventTouchUpInside];
        [canvasMonitorView addSubview:widthSlider];
        
        float previewWidth = sliderWidth*2.5/4;
        float previewTopMargin = 20;
        float previewHeight = 80;
        self.previewArea = [[ColorPreviewView alloc] initWithFrame:CGRectMake(sliderLeftMargin, previewTopMargin,
                                                                              previewWidth, previewHeight)];
        [self.previewArea setTag:kPreviewAreaTag];
        [self.colorSpectrumImageView registerDelegate:self.previewArea];
        [canvasMonitorView addSubview:self.previewArea];
        
        eraserButton = [[WBEraserButton alloc] init];
//        [eraserButton setTitle:@"Eraser" forState:UIControlStateNormal];
//        [eraserButton setFrame:CGRectMake(79, previewTopMargin*1.5, 60, previewHeight-2*previewTopMargin)];
        eraserButton.frame = CGRectMake(79, previewTopMargin, [eraserButton preferredSize].width, [eraserButton preferredSize].height);
        [eraserButton addTarget:self action:@selector(switchToEraser:) forControlEvents:UIControlEventTouchDown];
        [canvasMonitorView addSubview:eraserButton];
        
        // TODO: change to custom button
        float closeButtonSize = 44;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [closeButton setTitle:@"x" forState:UIControlStateNormal];
        [closeButton setFrame:CGRectMake(frame.size.width-closeButtonSize, 0, closeButtonSize, closeButtonSize)];
        [closeButton addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchDown];
        [self addSubview:closeButton];
    }
    return self;
}

- (void)opacityChanged:(CustomSlider *)opacitySlider {
    if ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) {
        return;
    }
    
    [[SettingManager sharedManager] setCurrentColorTabWithOpacity:opacitySlider.value];
    [self.previewArea setNeedsDisplay];
    [self.colorSpectrumImageView setNeedsDisplay];
    CGFloat opacity = 1.0-powf(1.0-opacitySlider.value, 1.0/([[SettingManager sharedManager] getCurrentColorTab].pointSize*[UIScreen mainScreen].scale));
    [[PaintingManager sharedManager] updateOpacity:opacity of:nil];
	
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(opacityChanged:)]) {
        [self.delegate opacityChanged:opacitySlider.value];
    }
}

- (void)invalidateOpacitySlider {
    [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kOpacitySliderTag]) setValue:[[SettingManager sharedManager] getCurrentColorTab].opacity animated:NO];
}

- (void)persistOpacity {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

- (void)pointSizeChanged:(CustomSlider *)widthSlider {
    [[SettingManager sharedManager] setCurrentColorTabWithPointSize:widthSlider.value];
    [self.previewArea setNeedsDisplay];
    [self.colorSpectrumImageView setNeedsDisplay];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pointSizeChanged:)]) {
        [self.delegate pointSizeChanged:widthSlider.value];
    }
}

- (void)invalidateWidthSlider {
    [((CustomSlider *) [[self viewWithTag:kCanvasMonitorTag] viewWithTag:kWidthSliderTag]) setValue:[[SettingManager sharedManager] getCurrentColorTab].pointSize animated:NO];
}

- (void)persistPointSize {
    [[SettingManager sharedManager] persistColorTabSettingAtCurrentIndex];
}

- (void)switchToEraser:(UIButton *)button {
    button.selected = YES;
    [[SettingManager sharedManager] setCurrentColorTab:kEraserTabIndex];
    [self.previewArea setNeedsDisplay];
}

- (void)closeMe {
    [self removeFromSuperview];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(monitorClosed)]) {
        [self.delegate monitorClosed];
    }
}

- (void)colorPicked:(UIColor *)color {
    
    eraserButton.selected = NO;
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(colorPicked:)]) {
        [self.delegate colorPicked:color];
    }
}

- (void)wantToPickColorWhenEraserIsActivated {
    [[SettingManager sharedManager] setCurrentColorTab:0];
}

@end
