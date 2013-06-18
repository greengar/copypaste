//
//  SettingManager.h
//  WhiteboardSDK
//
//  Created by Hector Zhao on 5/29/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorTabElement.h"
#import "PaintingManager.h"
#import "WBUtils.h"

#define kPointSizeKeyFormat                 @"kPointSizeKeyFormat%d"
#define kOpacityKeyFormat                   @"kOpacityKeyFormat%d"
#define kColorKeyFormat                     @"kColorKeyFormat%d"
#define kTextNameKey                        @"kTextNameKey"
#define kTextColorKey                       @"kTextColorKey"
#define kTextSizeKey                        @"kTextSizeKey"
#define kColorCoordinateKeyFormat           @"kColorCoordinateKeyFormat%d"

#define kDefaultOpacity			0.9
#define kCoolOpacity            0.9
#define kDefaultPointSize		18.0

#define kEraserTabIndex ((IS_IPAD) ? 6 : 3)

#define kAboutViewAnimationDuration 0.35

@class MCWhiteboard;

@interface SettingManager : NSObject

+ (SettingManager *) sharedManager;
+ (UIFont *) lightFontWithSize:(float)size;
+ (UIFont *) normalFontWithSize:(float)size;
+ (UIFont *) boldFontWithSize:(float)size;

#pragma mark Customize Getter and Setter for Color
- (ColorTabElement *) getCurrentColorTab;               // Get current drawing Color Tab
- (ColorTabElement *) getColorTabAtIndex:(int)index;    // Get Color Tab at valid index
- (int) getCurrentColorTabIndex;

- (void) setCurrentColorTab:(int)currentIndex;          // User can only set valid index for current Color Tab
- (void) setCurrentColorTabWithPointSize:(float)pointSize;
- (void) setCurrentColorTabWithOpacity:(float)opacity;
- (void) setCurrentColorTabWithColor:(UIColor *)color2
                           atOffsetX:(float)offsetX
                           atOffsetY:(float)offsetY;

- (void)swapColorHistory;

- (void)setupRenderPoint;
- (void)teardownRenderPoint;

#pragma mark Preference Load and Save
- (void) loadColorTabSetting;       // Called once only at first launch
- (void) loadTextSetting;

- (void) persistColorTabSetting;    // Must be called to persist all changed colors
- (void) persistColorTabSettingAtCurrentIndex;  // Must be called to persist current Color Tab
- (void) persistTextSetting;

@property (nonatomic)           float           textureScale;
@property (nonatomic, strong)   NSMutableArray  *colorTabList;
@property (nonatomic, strong)   NSString        *currentFontName;
@property (nonatomic, strong)   UIColor         *currentFontColor;
@property (nonatomic)           int             currentFontSize;

@end
