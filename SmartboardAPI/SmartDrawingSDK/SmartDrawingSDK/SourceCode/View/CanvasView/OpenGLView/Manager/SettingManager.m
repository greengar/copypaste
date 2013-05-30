 //
//  SettingManager.m
//  SmartDrawingSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "SettingManager.h"
#import "UIColor+GSString.h"
#import "SettingManager.h"
#import "SDUtils.h"

static SettingManager *shareManager = nil;

@implementation SettingManager

@synthesize textureScale, currentTool, currentShakeAction, isShowColorTab, isShakeActionConfirm, isEnablePanZoom, isEnableAutosave, colorTabList;

+ (SettingManager *)sharedManager { 
    static SettingManager *sharedManager; 
    static dispatch_once_t done; 
    dispatch_once(&done, ^{ sharedManager = [SettingManager new]; }); 
    return sharedManager;
}

+ (UIFont *)lightFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont systemFontOfSize:size];
    } else if ([SDUtils isIOS5OrHigher] == NO) {
        return [UIFont systemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"Gotham-Book" size:size];
    }
}

+ (UIFont *)normalFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont systemFontOfSize:size];
    } else if ([SDUtils isIOS5OrHigher] == NO) {
        return [UIFont systemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"Gotham-Medium" size:size];
    }
}

+ (UIFont *)boldFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont boldSystemFontOfSize:size];
    } else if ([SDUtils isIOS5OrHigher] == NO) {
        return [UIFont boldSystemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"Gotham-Bold" size:size];
    }
}

- (id) init {
    self = [super init];
    if (self) {
        if (IS_IPAD) {
            self.colorTabList = [[NSMutableArray alloc] initWithObjects:
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x8BB4F8)], // blue
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:[UIColor colorWithRed:0 green:0 blue:0 alpha:kCoolOpacity]],
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xBEBEBE)],
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xE78383)], // red
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFCC00)], // yellow
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA4FBB8)], // green
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:0
                                                                      color:OPAQUE_HEXCOLOR(0xFFFFFF)], // eraser
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA020F0)], // purple
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA52A2A)], // brown
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x000000)], // pure black
                        
                                 // Cut off for Portrait Mode
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFC0CB)], // pink
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFFFFF)], // behind
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xBEBEBE)], // grey
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xCCCCCC)], // light grey
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x990000)], // dark red
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x006600)], // dark green
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFFF00)], // yellow,
                                 nil];
        }
        else {
            self.colorTabList = [[NSMutableArray alloc] initWithObjects:
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xE78383)], // red
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA4FBB8)], // green
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x8BB4F8)], // blue
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFFFFF)], // eraser
                                 nil];
        }
        
        // Load Setting from Preferences
        [self loadColorTabSetting];
        [self loadGeneralSetting];
    }
    return self;
}

- (ColorTabElement *) getCurrentColorTab {
    return [self getColorTabAtIndex:currentColorTab];
}

- (ColorTabElement *) getColorTabAtIndex:(int)index {
    if (index >= 0 && index < [colorTabList count]) {
        return [self.colorTabList objectAtIndex:index];
    }
    return nil;
}

- (int) getCurrentColorTabIndex {
    return currentColorTab;
}

- (void) setCurrentColorTab:(int)currentIndex {
    if (currentIndex >= 0 && currentIndex < [self.colorTabList count]) {
        currentColorTab = currentIndex;
        ColorTabElement *currentTab = [self.colorTabList objectAtIndex:currentColorTab];
        
        // Save the color to Painting Manager
        [[PaintingManager sharedManager] updateColor:currentTab.tabColor.CGColor of:nil];
        
        // Save the more effective opacity to Painting Manager
        CGFloat effectiveTransformedOpacity = 1.0-powf(1.0-currentTab.opacity, 1.0/([UIScreen mainScreen].scale*currentTab.pointSize));
        [[PaintingManager sharedManager] updateOpacity:effectiveTransformedOpacity of:nil];
        
        // Save the brush size to Painting Manager
        [[PaintingManager sharedManager] updatePointSize:currentTab.pointSize of:nil];
        
        [self persistGeneralSetting];
    }
}

- (void) setCurrentColorTabWithPointSize:(float)pointSize {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:currentColorTab];
    currentTab.pointSize = pointSize;
    
    [[PaintingManager sharedManager] updatePointSize:pointSize of:nil];
    
    // don't persist here
}

- (void) setCurrentColorTabWithOpacity:(float)opacity {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:currentColorTab];
    currentTab.opacity = opacity;
    
    [[PaintingManager sharedManager] updateOpacity:opacity of:nil];
    
    // don't persist here
}

- (void) setCurrentColorTabWithColor:(UIColor *)color2 atOffsetX:(float)offsetX atOffsetY:(float)offsetY {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:currentColorTab];
    currentTab.tabColor = color2;
    currentTab.offsetXOnSpectrum = offsetX;
    currentTab.offsetYOnSpectrum = offsetY;
    
    [[PaintingManager sharedManager] updateColor:color2.CGColor of:nil];
    
    // don't persist here
}

- (void) loadColorTabSetting {
    currentColorTab = [[NSDEF objectForKey:kSelectedTabKey] intValue];
    
    if (currentColorTab < 0 || currentColorTab >= [colorTabList count]) { // Invalid current tab index, because of the different number of tabs on iPad and iPhone
        currentColorTab = [colorTabList count] - 1; // Set to the last valid tab
        
        if (currentColorTab == kEraserTabIndex) { // But if it's the eraser
            currentColorTab = currentColorTab - 1; // We should use another color tab instead
        }
        
        if (currentColorTab < 0 || currentColorTab >= [colorTabList count]) { // Just to be save
            currentColorTab = 0; // If we try to use one valid tab and the current index of color tab is invalid again, just use the first color tab
        }
    }
    
    for (int i = 0; i < [self.colorTabList count]; i++) {
        
        ColorTabElement *currentTab = [colorTabList objectAtIndex:i];
        
        NSNumber *number = [NSDEF objectForKey:[NSString stringWithFormat:kPointSizeKeyFormat, i]];
        if (number) {
            currentTab.pointSize = [number floatValue];
        }
        number = [NSDEF objectForKey:[NSString stringWithFormat:kOpacityKeyFormat, i]];
        if (number && i != kEraserTabIndex) {
            currentTab.opacity = [number floatValue];
        }
        NSString *colorString = [NSDEF objectForKey:[NSString stringWithFormat:kColorKeyFormat, i]];
        if (colorString && i != kEraserTabIndex) {
            float offsetX, offsetY;
            UIColor *savedColor = [UIColor gsColorFromString:colorString
                                                           x:&offsetX
                                                           y:&offsetY];
            if (savedColor) {
                currentTab.tabColor = savedColor;
                currentTab.offsetXOnSpectrum = offsetX;
                currentTab.offsetYOnSpectrum = offsetY;
            }
        }
    }
}

- (void) loadGeneralSetting {
    self.currentShakeAction = [NSDEF integerForKey:kCurrentShakeActionPreference];
    self.isShakeActionConfirm = [NSDEF boolForKey:kIsShakeActionConfirmPreference];
    self.isShowColorTab = [NSDEF boolForKey:kIsShowColorTabPreference];
    self.isEnablePanZoom = YES; // [NSDEF boolForKey:kIsEnablePanZoomPreference];
    self.isEnableAutosave = [NSDEF boolForKey:kIsEnableAutosavePreference];
}

- (void) loadAboutSetting {
    self.isShowColorTab = [NSDEF boolForKey:kIsShowColorTabPreference];
    self.isEnablePanZoom = [NSDEF boolForKey:kIsEnablePanZoomPreference];
}

- (void) loadEraserSetting {        
    self.currentShakeAction = [NSDEF integerForKey:kCurrentShakeActionPreference];
    self.isShakeActionConfirm = [NSDEF boolForKey:kIsShakeActionConfirmPreference];
}

- (void) persistColorTabSetting {
    for (int i = 0; i < [colorTabList count]; i++) {
        ColorTabElement *currentTab = [colorTabList objectAtIndex:i];
        [NSDEF setObject:[NSNumber numberWithFloat:currentTab.opacity] forKey:[NSString stringWithFormat:kOpacityKeyFormat, i]];
        [NSDEF setObject:[NSNumber numberWithFloat:currentTab.pointSize] forKey:[NSString stringWithFormat:kPointSizeKeyFormat, i]];
        [NSDEF setObject:[currentTab.tabColor gsStringWithX:currentTab.offsetXOnSpectrum
                                                          y:currentTab.offsetYOnSpectrum]
                  forKey:[NSString stringWithFormat:kColorKeyFormat, i]];
    }
    
    [NSDEF synchronize];
}

- (void) persistColorTabSettingAtCurrentIndex {
    ColorTabElement *currentTab = [colorTabList objectAtIndex:currentColorTab];
    [NSDEF setObject:[NSNumber numberWithFloat:currentTab.opacity] forKey:[NSString stringWithFormat:kOpacityKeyFormat, currentColorTab]];
    [NSDEF setObject:[NSNumber numberWithFloat:currentTab.pointSize] forKey:[NSString stringWithFormat:kPointSizeKeyFormat, currentColorTab]];
    [NSDEF setObject:[currentTab.tabColor gsStringWithX:currentTab.offsetXOnSpectrum
                                                      y:currentTab.offsetYOnSpectrum]
              forKey:[NSString stringWithFormat:kColorKeyFormat, currentColorTab]];
    [NSDEF synchronize];
}

- (void) persistGeneralSetting {
    [NSDEF setInteger:self.currentShakeAction forKey:kCurrentShakeActionPreference];
    [NSDEF setBool:self.isShakeActionConfirm forKey:kIsShakeActionConfirmPreference];
    [NSDEF setBool:self.isEnablePanZoom forKey:kIsEnablePanZoomPreference];
    [NSDEF setBool:self.isShowColorTab forKey:kIsShowColorTabPreference];
    [NSDEF setBool:self.isEnableAutosave forKey:kIsEnableAutosavePreference];
    [NSDEF setInteger:currentColorTab forKey:kSelectedTabKey];
    [NSDEF synchronize];
}

- (void) persistAboutSetting {
    [NSDEF setBool:self.isEnablePanZoom forKey:kIsEnablePanZoomPreference];
    [NSDEF setBool:self.isShowColorTab forKey:kIsShowColorTabPreference];
    [NSDEF synchronize];
}

- (void) persistEraserSetting {
    [NSDEF setInteger:self.currentShakeAction forKey:kCurrentShakeActionPreference];
    [NSDEF setBool:self.isShakeActionConfirm forKey:kIsShakeActionConfirmPreference];
    [NSDEF setBool:self.isEnableAutosave forKey:kIsEnableAutosavePreference];
    [NSDEF synchronize];
}

- (void)setupRenderPoint {
    tempOpacity = [[[PaintingManager sharedManager] getPainting:nil] getColor][3];
    [[PaintingManager sharedManager] updateOpacity:(1.0 - powf(1.0 - tempOpacity, [[PaintingManager sharedManager] getPointSizeOf:nil]*[UIScreen mainScreen].scale )) of:nil];
}

- (void)teardownRenderPoint {
    [[PaintingManager sharedManager] updateOpacity:tempOpacity of:nil];
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (shareManager == nil) {
            shareManager = [super allocWithZone:zone];
            return shareManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
