//
//  ColorTabView.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "ColorTabView.h"
#import "SDUtils.h"
#import "TabWrapperView.h"
#import "SettingManager.h"

#define kHideShowButtonHeight 50

@interface ColorTabView()
@property (nonatomic, strong) UIImageView *hideShowImageInTabArray;
@end
@implementation ColorTabView
@synthesize tabArray = _tabArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor darkGrayColor]];
        [self initTabArray];
        [self initializeHideShowButtonInTabArray];
    }
    return self;
}

#pragma mark - Tab Arrays
- (void)initTabArray {
    if (IS_IPAD) {
        // iPad: 17 tabs
        self.tabArray = [[NSArray alloc] initWithObjects:[[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         
                                                         // Landscape
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init], nil];
        
    } else {
        // iPhone: 4 tabs
        self.tabArray = [[NSArray alloc] initWithObjects:[[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init],
                                                         [[TabWrapperView alloc] init], nil];
    }
    
    for (int i = 0; i < [self.tabArray count]; i++) {
        TabWrapperView *tab = [self.tabArray objectAtIndex:i];
        tab.displayView.frame = CGRectMake((i * kTabWidth) + kColorTabOriginX, kColorTabOriginY, kColorTabWidth, kColorTabHeight);
        tab.displayView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        tab.displayView.circleColor = [[SettingManager sharedManager] getColorTabAtIndex:i].tabColor;
        tab.displayView.circleOpacity = [[SettingManager sharedManager] getColorTabAtIndex:i].opacity;
        tab.displayView.circlePointSize = [[SettingManager sharedManager] getColorTabAtIndex:i].pointSize;
        
        tab.eventView.frame = CGRectMake((i * kTabWidth), 0, kTabWidth, kLauncherHeight);
        [tab.eventView addTarget:self action:@selector(setSelectedTab:) forControlEvents:UIControlEventTouchUpInside];
        
        // Hector: do not show color tab under Arrow Button
        if (i == kHideShowButtonInTabArrayIndex) {
            
        } else if (i == kEraserTabIndex) {
            [self addSubview:tab.eventView];
        } else {
            [self addSubview:tab.eventView];
            [self addSubview:tab.displayView];
        }
    }
    
    UIImageView *eraserButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SmartDrawing.bundle/Eraser.png"]
                                                  highlightedImage:[UIImage imageNamed:@"SmartDrawing.bundle/Eraser.png"]];
    eraserButton.frame = CGRectMake((kEraserTabIndex * kTabWidth) + 19, 13, 27, 21);
    [self addSubview:eraserButton];
    
    [self setSelectedTab:0];
}

- (void)setSelectedTab:(id)sender {
    for (TabWrapperView *tab in self.tabArray) {
        [tab setSelected:NO];
    }
    int offset = ((UIButton *)sender).frame.origin.x / kTabWidth;
    [(TabWrapperView *)[self.tabArray objectAtIndex:offset] setSelected:YES];
    [[SettingManager sharedManager] setCurrentColorTab:offset];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectColorTabAtIndex:)]) {
        [self.delegate selectColorTabAtIndex:offset];
    }
}

- (void)updateColorTab {
    TabWrapperView *tab = [self.tabArray objectAtIndex:[[SettingManager sharedManager] getCurrentColorTabIndex]];
    tab.displayView.circlePointSize = [[SettingManager sharedManager] getCurrentColorTab ].pointSize;
    tab.displayView.circleOpacity = [[SettingManager sharedManager] getCurrentColorTab ].opacity;
    tab.displayView.circleColor = [[SettingManager sharedManager] getCurrentColorTab].tabColor;
    [tab.displayView setNeedsDisplay];
}

#pragma mark - Hide/Show buttons
- (void)initializeHideShowButtonInTabArray {
    UIButton *hideShowButtonInTabArray = [UIButton buttonWithType:UIButtonTypeCustom];
    [hideShowButtonInTabArray setImage:[UIImage imageNamed:@"SmartDrawing.bundle/HideShowButton.png"] forState:UIControlStateNormal];
    [hideShowButtonInTabArray setContentMode:UIViewContentModeTopLeft];
    hideShowButtonInTabArray.frame = CGRectMake((kHideShowButtonInTabArrayIndex * kTabWidth), -5, kTabWidth, kHideShowButtonHeight);
    [hideShowButtonInTabArray addTarget:self action:@selector(hideShowButtonInTabArrayTouchDown:)
                       forControlEvents:UIControlEventTouchDown];
    [hideShowButtonInTabArray addTarget:self action:@selector(hideShowButtonInTabArrayTouchDragExit:)
                       forControlEvents:UIControlEventTouchDragExit];
    [hideShowButtonInTabArray addTarget:self action:@selector(hideShowButtonInTabArrayTouchDragEnter:)
                       forControlEvents:UIControlEventTouchDragEnter];
    [hideShowButtonInTabArray addTarget:self action:@selector(showHidePicker) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideShowButtonInTabArray];
    
    self.hideShowImageInTabArray = [[UIImageView alloc] initWithImage:
                                    [UIImage imageNamed:@"SmartDrawing.bundle/arrow_down_48.png"]
                                                     highlightedImage:
                                    [UIImage imageNamed:@"SmartDrawing.bundle/arrow_down_48_highlighted.png"]];
    self.hideShowImageInTabArray.frame = CGRectMake((kHideShowButtonInTabArrayIndex*kTabWidth)+kHideShowButtonInTabArrayOriginX, kHideShowButtonInTabArrayOriginY, kHideShowButtonInTabArrayWidth, kHideShowButtonInTabArrayHeight);
    [self addSubview:self.hideShowImageInTabArray];
}

- (void)hideShowButtonAtCornerTouchDown:(UIButton *)b {
    b.highlighted = YES;
    b.alpha = 1.0;
}

- (void)hideShowButtonInTabArrayTouchDragExit:(UIButton *)b {
    b.highlighted = NO;
    b.alpha = 0.7;
}

- (void)hideShowButtonInTabArrayTouchDragEnter:(UIButton *)b {
    b.highlighted = YES;
    b.alpha = 1.0;
}

- (void)hideShowButtonInTabArrayTouchDown:(UIButton *)b {
    b.highlighted = YES;
    b.alpha = 1.0;
}

- (void)showHidePicker {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showHidePicker)]) {
        [self.delegate showHidePicker];
    }
}

- (void)finishShowHidePicker:(BOOL)isShown {
    if (isShown) {
        self.hideShowImageInTabArray.image = [UIImage imageNamed:@"SmartDrawing.bundle/arrow_down_48.png"];
        self.hideShowImageInTabArray.highlightedImage = [UIImage imageNamed:@"SmartDrawing.bundle/arrow_down_48_highlighted.png"];
    } else {
        self.hideShowImageInTabArray.image = [UIImage imageNamed:@"SmartDrawing.bundle/arrow_up_48.png"];
        self.hideShowImageInTabArray.highlightedImage = [UIImage imageNamed:@"SmartDrawing.bundle/arrow_up_48_highlighted.png"];
    }
}

@end
