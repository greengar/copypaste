 //
//  SettingManager.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import "SettingManager.h"
#import "UIColor+GSString.h"
#import "SettingManager.h"
#import "WBUtils.h"

static SettingManager *shareManager = nil;

@interface SettingManager()
@property (nonatomic)           int             currentColorTab;
@property (nonatomic)           CGFloat         tempOpacity;
@property (nonatomic)           NSString        *mySecretId;
@end

@implementation SettingManager
@synthesize currentColorTab =_currentColorTab;
@synthesize tempOpacity = _tempOpacity;
@synthesize textureScale = _textureScale;
@synthesize colorTabList = _colorTabList;
@synthesize currentFontName = _currentFontName;
@synthesize currentFontSize = _currentFontSize;
@synthesize currentFontColor = _currentFontColor;
@synthesize viewOnly = _viewOnly;

+ (SettingManager *)sharedManager { 
    static SettingManager *sharedManager; 
    static dispatch_once_t done; 
    dispatch_once(&done, ^{ sharedManager = [SettingManager new]; }); 
    return sharedManager;
}

+ (UIFont *)lightFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont systemFontOfSize:size];
    } else if ([WBUtils isIOS5OrHigher] == NO) {
        return [UIFont systemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"Gotham-Book" size:size];
    }
}

+ (UIFont *)normalFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont systemFontOfSize:size];
    } else if ([WBUtils isIOS5OrHigher] == NO) {
        return [UIFont systemFontOfSize:size];
    } else {
        return [UIFont fontWithName:@"Gotham-Medium" size:size];
    }
}

+ (UIFont *)boldFontWithSize:(float)size {
    if (IS_IPAD1) {
        return [UIFont boldSystemFontOfSize:size];
    } else if ([WBUtils isIOS5OrHigher] == NO) {
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
                                                                      color:OPAQUE_HEXCOLOR(0xE78383)], // red
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA4FBB8)], // green
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0x8BB4F8)], // blue
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFC0CB)], // pink
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xFFFF00)], // yellow,
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:kCoolOpacity
                                                                      color:OPAQUE_HEXCOLOR(0xA52A2A)], // brown
                                 [[ColorTabElement alloc] initWithPointSize:kDefaultPointSize
                                                                    opacity:0
                                                                      color:OPAQUE_HEXCOLOR(0xFFFFFF)], // eraser
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
                                                                    opacity:0
                                                                      color:OPAQUE_HEXCOLOR(0xFFFFFF)], // eraser
                                 nil];
        }
        
        // Load Setting from Preferences
        [self loadColorTabSetting];
        [self loadTextSetting];
        
        [self setCurrentColorTab:0];
    }
    return self;
}

- (ColorTabElement *) getCurrentColorTab {
    return [self getColorTabAtIndex:self.currentColorTab];
}

- (ColorTabElement *) getColorTabAtIndex:(int)index {
    if (index >= 0 && index < [self.colorTabList count]) {
        return [self.colorTabList objectAtIndex:index];
    }
    return nil;
}

- (int) getCurrentColorTabIndex {
    return self.currentColorTab;
}

- (void) setCurrentColorTab:(int)currentIndex {
    if (currentIndex >= 0 && currentIndex < [self.colorTabList count]) {
        _currentColorTab = currentIndex;
        ColorTabElement *currentTab = [self.colorTabList objectAtIndex:self.currentColorTab];
        
        // Save the color to Painting Manager
        [[PaintingManager sharedManager] updateColor:currentTab.tabColor.CGColor of:nil];
        
        // Save the more effective opacity to Painting Manager
        CGFloat effectiveTransformedOpacity = 1.0-powf(1.0-currentTab.opacity, 1.0/([UIScreen mainScreen].scale*currentTab.pointSize));
        [[PaintingManager sharedManager] updateOpacity:effectiveTransformedOpacity of:nil];
        
        // Save the brush size to Painting Manager
        [[PaintingManager sharedManager] updatePointSize:currentTab.pointSize of:nil];
    }
}

- (void) setCurrentColorTabWithPointSize:(float)pointSize {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:self.currentColorTab];
    currentTab.pointSize = pointSize;
    
    [[PaintingManager sharedManager] updatePointSize:pointSize of:nil];
}

- (void) setCurrentColorTabWithOpacity:(float)opacity {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:self.currentColorTab];
    currentTab.opacity = opacity;
    
    CGFloat effectiveTransformedOpacity = 1.0-powf(1.0-currentTab.opacity, 1.0/([UIScreen mainScreen].scale*currentTab.pointSize));
    [[PaintingManager sharedManager] updateOpacity:effectiveTransformedOpacity of:nil];
}

- (void) setCurrentColorTabWithColor:(UIColor *)color2 atOffsetX:(float)offsetX atOffsetY:(float)offsetY {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:self.currentColorTab];
    currentTab.tabColor = color2;
    currentTab.offsetXOnSpectrum = offsetX;
    currentTab.offsetYOnSpectrum = offsetY;
    
    [[PaintingManager sharedManager] updateColor:color2.CGColor of:nil];
}

- (void)swapColorHistory {
    // Keep the first color
    ColorTabElement *firstTab = [self.colorTabList objectAtIndex:0];
    ColorTabElement *newColorTab = [[ColorTabElement alloc] initWithPointSize:firstTab.pointSize
                                                                      opacity:firstTab.opacity
                                                                        color:firstTab.tabColor];
    // Swap each color by its previous one
    for (int i = [self.colorTabList count]-2; i > 0; i--) {
        ColorTabElement *currentTab = [self.colorTabList objectAtIndex:i];
        ColorTabElement *previousTab = [self.colorTabList objectAtIndex:i-1];
        currentTab = previousTab;
    }
    
    // Remove the one before Eraser
    [self.colorTabList removeObjectAtIndex:([self.colorTabList count]-2)];
    
    // Add the new color
    [self.colorTabList insertObject:newColorTab atIndex:0];
    
}

- (void) loadColorTabSetting {
    for (int i = 0; i < [self.colorTabList count]; i++) {
        ColorTabElement *currentTab = [self.colorTabList objectAtIndex:i];
        
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

- (void) loadTextSetting {
    NSNumber *sizeNumber = [NSDEF objectForKey:kTextSizeKey];
    if (sizeNumber) {
        self.currentFontSize = [sizeNumber intValue];
    } else {
        self.currentFontSize = kDefaultFontSize;
    }
    
    NSString *fontString = [NSDEF objectForKey:kTextNameKey];
    if (fontString) {
        self.currentFontName = fontString;
    } else {
        self.currentFontName = kDefaultFontName;
    }
    
    NSString *colorString = [NSDEF objectForKey:kTextColorKey];
    if (colorString) {
        self.currentFontColor = [UIColor gsColorFromString:colorString];
    } else {
        self.currentFontColor = [UIColor darkGrayColor];
    }
}

- (void) persistColorTabSetting {
    for (int i = 0; i < [self.colorTabList count]; i++) {
        ColorTabElement *currentTab = [self.colorTabList objectAtIndex:i];
        [NSDEF setObject:[NSNumber numberWithFloat:currentTab.opacity] forKey:[NSString stringWithFormat:kOpacityKeyFormat, i]];
        [NSDEF setObject:[NSNumber numberWithFloat:currentTab.pointSize] forKey:[NSString stringWithFormat:kPointSizeKeyFormat, i]];
        [NSDEF setObject:[currentTab.tabColor gsStringWithX:currentTab.offsetXOnSpectrum
                                                          y:currentTab.offsetYOnSpectrum]
                  forKey:[NSString stringWithFormat:kColorKeyFormat, i]];
    }
    
    [NSDEF synchronize];
}

- (void) persistTextSetting {
    [NSDEF setObject:self.currentFontName forKey:kTextNameKey];
    [NSDEF setObject:[self.currentFontColor gsString] forKey:kTextColorKey];
    [NSDEF setObject:[NSNumber numberWithInt:self.currentFontSize] forKey:kTextSizeKey];
    [NSDEF synchronize];
}

- (void) persistColorTabSettingAtCurrentIndex {
    ColorTabElement *currentTab = [self.colorTabList objectAtIndex:self.currentColorTab];
    [NSDEF setObject:[NSNumber numberWithFloat:currentTab.opacity] forKey:[NSString stringWithFormat:kOpacityKeyFormat, self.currentColorTab]];
    [NSDEF setObject:[NSNumber numberWithFloat:currentTab.pointSize] forKey:[NSString stringWithFormat:kPointSizeKeyFormat, self.currentColorTab]];
    [NSDEF setObject:[currentTab.tabColor gsStringWithX:currentTab.offsetXOnSpectrum
                                                      y:currentTab.offsetYOnSpectrum]
              forKey:[NSString stringWithFormat:kColorKeyFormat, self.currentColorTab]];
    [NSDEF synchronize];
}

- (void)setupRenderPoint {
    self.tempOpacity = [[[PaintingManager sharedManager] getPainting:nil] getColor][3];
    [[PaintingManager sharedManager] updateOpacity:(1.0 - powf(1.0 - self.tempOpacity, [[PaintingManager sharedManager] getPointSizeOf:nil]*[UIScreen mainScreen].scale )) of:nil];
}

- (void)teardownRenderPoint {
    [[PaintingManager sharedManager] updateOpacity:self.tempOpacity of:nil];
}

+ (void)resetSecretId {
    NSString *mac = [[WBUtils getMacAddress] stringByReplacingOccurrencesOfString:@":" withString:@"i"];
    [SettingManager sharedManager].mySecretId = [NSString stringWithFormat:@"%@%@", mac, [WBUtils generateUniqueId]];
}

+ (NSString *)mySecretId {
    if ([[SettingManager sharedManager] mySecretId]) {
        return [[SettingManager sharedManager] mySecretId];
    } else  {
        [SettingManager resetSecretId];
        return [[SettingManager sharedManager] mySecretId];
    }
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