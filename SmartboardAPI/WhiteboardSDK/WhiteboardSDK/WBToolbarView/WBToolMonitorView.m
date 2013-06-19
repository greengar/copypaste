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

@interface WBToolMonitorView() {
    UIView                 *toolMonitorView;
    ColorSpectrumImageView *colorSpectrumImageView;
    UIView                 *canvasMonitorView;
    CustomSlider           *widthSlider;
    CustomSlider           *opacitySlider;
    ColorPreviewView       *previewArea;
    WBEraserButton         *eraserButton;
    BOOL                   isAnimationUp;
    BOOL                   isAnimationDown;
}
@end

@implementation WBToolMonitorView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        // Use an inside view for doing the animation
        toolMonitorView = [[UIView alloc] initWithFrame:CGRectMake(0, kOffsetForBouncing, frame.size.width, frame.size.height-kOffsetForBouncing)];
        toolMonitorView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        toolMonitorView.clipsToBounds = YES;
        toolMonitorView.layer.cornerRadius = 5;
        toolMonitorView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        toolMonitorView.layer.borderWidth = 1;
        [self addSubview:toolMonitorView];
        
        UIImage *colorSpectrumImage = [UIImage imageNamed:@"Whiteboard.bundle/ColorSpectrumPublic.png"];
        colorSpectrumImageView = [[ColorSpectrumImageView alloc] initWithImage:colorSpectrumImage];
        [colorSpectrumImageView setFrame:CGRectMake(0, 0, colorSpectrumImage.size.width, colorSpectrumImage.size.height)];
        [colorSpectrumImageView setUserInteractionEnabled:YES];
        [colorSpectrumImageView registerDelegate:self];
        [toolMonitorView addSubview:colorSpectrumImageView];
        
        canvasMonitorView = [[UIView alloc] initWithFrame:CGRectMake(colorSpectrumImage.size.width, 0,
                                                                     frame.size.width-colorSpectrumImage.size.width,
                                                                     colorSpectrumImage.size.height)];
        [canvasMonitorView setBackgroundColor:[UIColor clearColor]];
        [toolMonitorView addSubview:canvasMonitorView];
        
        float sliderLeftMargin = 10;
        float sliderWidth = frame.size.width-colorSpectrumImage.size.width-2*sliderLeftMargin;
        float sliderHeight = 20;
        opacitySlider = [[CustomSlider alloc] initWithFrame:CGRectMake(sliderLeftMargin,
                                                                       colorSpectrumImage.size.height-40,
                                                                       sliderWidth,
                                                                       sliderHeight)];
        opacitySlider.backgroundColor = [UIColor clearColor];
        opacitySlider.minimumValue = 0.19f;
        opacitySlider.maximumValue = 1.0f;
        opacitySlider.continuous = YES;
        opacitySlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        opacitySlider.enabled = !([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex);
        opacitySlider.value = ([[SettingManager sharedManager] getCurrentColorTabIndex] == kEraserTabIndex) ? 1.0f :[[SettingManager sharedManager] getCurrentColorTab].opacity;
        [opacitySlider setMinimumTitle:@"0%"];
        [opacitySlider setMaximumTitle:@"100%"];
        [opacitySlider addTarget:self action:@selector(opacityChanged:) forControlEvents:UIControlEventValueChanged];
        [opacitySlider addTarget:self action:@selector(persistOpacity) forControlEvents:UIControlEventTouchUpInside];
        [canvasMonitorView addSubview:opacitySlider];
        
        widthSlider = [[CustomSlider alloc] initWithFrame:CGRectMake(sliderLeftMargin,
                                                                     colorSpectrumImage.size.height-80,
                                                                     sliderWidth,
                                                                     sliderHeight)];
        widthSlider.backgroundColor = [UIColor clearColor];
        widthSlider.minimumValue = kMinPointSize;
        widthSlider.maximumValue = kMaxPointSize;
        widthSlider.continuous = YES;
        widthSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        widthSlider.value = [[SettingManager sharedManager] getCurrentColorTab].pointSize;
        [widthSlider setMinimumTitle:@"-"];
        [widthSlider setMaximumTitle:@"+"];
        [widthSlider addTarget:self action:@selector(pointSizeChanged:) forControlEvents:UIControlEventValueChanged];
        [widthSlider addTarget:self action:@selector(persistPointSize) forControlEvents:UIControlEventTouchUpInside];
        [canvasMonitorView addSubview:widthSlider];
        
        float previewWidth = sliderWidth*2.5/4;
        float previewTopMargin = 20;
        float previewHeight = 80;
        previewArea = [[ColorPreviewView alloc] initWithFrame:CGRectMake(sliderLeftMargin, previewTopMargin,
                                                                         previewWidth, previewHeight)];
        [colorSpectrumImageView registerDelegate:previewArea];
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
        [toolMonitorView addSubview:closeButton];
    }
    return self;
}

#pragma mark - Animation
- (void)animateUp {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height*2];
    NSValue * to = [NSNumber numberWithFloat:(self.frame.size.height+kOffsetForBouncing)/2];
    NSString * keypath = @"position.y";
    
    [toolMonitorView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                                  to:to
                                                          forKeyPath:keypath
                                                        withDuration:.6
                                                            delegate:self]
                                                      forKey:@"bounce"];
    [toolMonitorView.layer setValue:to forKeyPath:keypath];
    isAnimationUp = YES;
}

- (void)animateDown {
    NSValue * from = [NSNumber numberWithFloat:self.frame.size.height/2];
    NSValue * to = [NSNumber numberWithFloat:self.frame.size.height*2];
    NSString * keypath = @"position.y";
    
    [toolMonitorView.layer addAnimation:[WBUtils bounceAnimationFrom:from
                                                                  to:to
                                                          forKeyPath:keypath
                                                        withDuration:.6
                                                            delegate:self]
                                                      forKey:@"bounce"];
    [toolMonitorView.layer setValue:to forKeyPath:keypath];
    isAnimationDown = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (isAnimationUp) {
        isAnimationUp = NO;
    }
    
    if (isAnimationDown) {
        [self removeFromSuperview];
        isAnimationDown = NO;
    }
}

#pragma mark - Update UI
- (void)invalidateOpacitySlider {
    [opacitySlider setValue:[[SettingManager sharedManager] getCurrentColorTab].opacity animated:NO];
}

- (void)invalidatePreviewArea {
    [previewArea setNeedsDisplay];
}

- (void)invalidateWidthSlider {
    [widthSlider setValue:[[SettingManager sharedManager] getCurrentColorTab].pointSize animated:NO];
}

- (void)enableEraser:(BOOL)enable {
    if (enable) {
        eraserButton.selected = YES;
        [opacitySlider setEnabled:NO];
        [opacitySlider setValue:1.0f animated:NO];
    } else {
        eraserButton.selected = NO;
        [opacitySlider setEnabled:YES];
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
- (void)pointSizeChanged:(CustomSlider *)widthSlider_ {
    [[SettingManager sharedManager] setCurrentColorTabWithPointSize:widthSlider_.value];
    [self invalidatePreviewArea];
    [colorSpectrumImageView setNeedsDisplay];
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(pointSizeChanged:)]) {
        [self.delegate pointSizeChanged:widthSlider.value];
    }
}

- (void)opacityChanged:(CustomSlider *)opacitySlider_ {
    [[SettingManager sharedManager] setCurrentColorTabWithOpacity:opacitySlider_.value];
    [self invalidatePreviewArea];
    [colorSpectrumImageView setNeedsDisplay];
	
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
    [self animateDown];
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (point.y > kOffsetForBouncing) {
        return hitView;
    }
    return nil;
}

@end
