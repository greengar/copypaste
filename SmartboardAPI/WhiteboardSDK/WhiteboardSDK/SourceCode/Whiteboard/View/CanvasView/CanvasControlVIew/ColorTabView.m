//
//  ColorTabView.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/28/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "ColorTabView.h"
#import "WBUtils.h"
#import "TabWrapperView.h"
#import "SettingManager.h"

#define kTabWidth 64

// Color Tab in Bottom of Screen (21, 21, 22, 23)
#define kColorTabOriginX 20
#define kColorTabOriginY 21
#define kColorTabWidth 24
#define kColorTabHeight 23

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
        if (i == kEraserTabIndex) {
            [self addSubview:tab.eventView];
        } else {
            [self addSubview:tab.eventView];
            [self addSubview:tab.displayView];
        }
    }
    
    UIImageView *eraserButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Whiteboard.bundle/Eraser.png"]
                                                  highlightedImage:[UIImage imageNamed:@"Whiteboard.bundle/Eraser.png"]];
    eraserButton.frame = CGRectMake((kEraserTabIndex * kTabWidth) + 19, 23, 27, 21);
    [self addSubview:eraserButton];
    
    [self setSelectedTab:((TabWrapperView *)[self.tabArray objectAtIndex:0]).eventView];
}

- (void)setSelectedTab:(id)sender {
    for (TabWrapperView *tab in self.tabArray) {
        [tab setSelected:NO];
    }
    int index = ((UIButton *)sender).frame.origin.x/kTabWidth;
    [(TabWrapperView *)[self.tabArray objectAtIndex:index] setSelected:YES];
    if ([[SettingManager sharedManager] getCurrentColorTabIndex] == index) {
        [self showHidePicker];
    }
    [[SettingManager sharedManager] setCurrentColorTab:index];
    
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(selectColorTabAtIndex:)]) {
        [self.delegate selectColorTabAtIndex:index];
    }
}

- (void)updateColorTab {
    TabWrapperView *tab = [self.tabArray objectAtIndex:[[SettingManager sharedManager] getCurrentColorTabIndex]];
    tab.displayView.circlePointSize = [[SettingManager sharedManager] getCurrentColorTab ].pointSize;
    tab.displayView.circleOpacity = [[SettingManager sharedManager] getCurrentColorTab ].opacity;
    tab.displayView.circleColor = [[SettingManager sharedManager] getCurrentColorTab].tabColor;
    [tab.displayView setNeedsDisplay];
}

- (void)showHidePicker {
    if (self.delegate && [((id) self.delegate) respondsToSelector:@selector(showHidePicker)]) {
        [self.delegate showHidePicker];
    }
}

@end
