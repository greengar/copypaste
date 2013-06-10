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

#define kCurrentShakeActionPreference       @"ShakePreference"
#define kIsShakeActionConfirmPreference     @"ConfirmStartOverPreference"
#define kIsShowColorTabPreference           @"TabSwitchPreference"
#define kIsEnablePanZoomPreference          @"PanZoomSwitchPreference"
#define kIsEnableAutosavePreference         @"AutosaveSwitchPreference"
#define kSelectedTabKey                     @"kSelectedTabKey"
#define kPointSizeKeyFormat                 @"kPointSizeKeyFormat%d"
#define kOpacityKeyFormat                   @"kOpacityKeyFormat%d"
#define kToolKeyFormat                      @"kToolKeyFormat%d"
#define kColorKeyFormat                     @"kColorKeyFormat%d"
#define kTextNameKey                        @"kTextNameKey"
#define kTextColorKey                       @"kTextColorKey"
#define kTextSizeKey                        @"kTextSizeKey"
#define kColorCoordinateKeyFormat           @"kColorCoordinateKeyFormat%d"

#define kUpdateUndoRedoNotification         @"Update Undo Redo Notification"
#define kShowHideLauncherNotification       @"Show Hide Launcher Notification"
#define kHideRedoNotification               @"Hide Redo Notification"
#define kShowMenuNotification               @"Show Menu Notification"
#define kHideMenuNotification               @"Hide Menu Notification"
#define kShowConnectionNotification         @"Show Connection Notification"
#define kHideConnectionNotification         @"Hide Connection Notification"
#define kPerformUndoNotification            @"Perform Undo Notification"
#define kPerformRedoNotification            @"Perform Redo Notification"

#define kOpacityChangedNotification         @"Opacity Changed Notification"
#define kPointSizeChangedNotification       @"Point Size Changed Notification"
#define kShowTextToolViewNotification       @"Show Text Tool View Notification"
#define kHideTextToolViewNotification       @"Hide Text Tool View Notification"

#define kLastTimeCheckFullScreenAdUpdateKey @"kLastTimeCheckFullScreenAdUpdateKey"
#define kTimeToCheckFullScreenAdKey         @"kTimeToCheckFullScreenAdKey"

#define kDefaultOpacity			0.9
#define kCoolOpacity            0.9
#define kDefaultPointSize		9.0

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

- (void)setupRenderPoint;
- (void)teardownRenderPoint;

#pragma mark Preference Load and Save
- (void) loadColorTabSetting;       // Called once only at first launch
- (void) loadGeneralSetting;        // Called once only at first launch
- (void) loadAboutSetting;
- (void) loadEraserSetting;
- (void) loadTextSetting;
- (void) persistColorTabSetting;    // Must be called to persist all changed colors
- (void) persistColorTabSettingAtCurrentIndex;  // Must be called to persist current Color Tab
- (void) persistGeneralSetting;     // Must be called to persist all general settings
- (void) persistAboutSetting;
- (void) persistEraserSetting;
- (void) persistTextSetting;

@property (nonatomic)           float           textureScale;
@property (nonatomic, strong)   NSMutableArray  *colorTabList;
@property (nonatomic)           ToolType        currentTool;
@property (nonatomic)           ShakeActionType currentShakeAction;
@property (nonatomic)           BOOL            isShakeActionConfirm;
@property (nonatomic)           BOOL            isShowColorTab;
@property (nonatomic)           BOOL            isEnablePanZoom;
@property (nonatomic)           BOOL            isEnableAutosave;
@property (nonatomic, strong)   NSString        *currentFontName;
@property (nonatomic, strong)   UIColor         *currentFontColor;
@property (nonatomic)           int             currentFontSize;

@end
