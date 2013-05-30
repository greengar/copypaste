//
//  SDSUtils.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_IPAD      (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
#define IS_IPAD1    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale == 1.0) && (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
#define IS_IPAD2    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale == 1.0) &&([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
#define IS_IPAD3    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale != 1.0))
#define IS_IPHONE5  ([[UIScreen mainScreen] bounds].size.height == 568)

#ifdef DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#       define DLog(...)
#endif

#define NSDEF [NSUserDefaults standardUserDefaults]

#define OPAQUE_HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:0.9]

#define kCPBackgroundColor OPAQUE_HEXCOLOR(0xE1CAA7)
#define kCPPasteTextColor OPAQUE_HEXCOLOR(0xFA891F)
#define kCPLightOrangeColor OPAQUE_HEXCOLOR(0xF7A058)

typedef enum {
    kUnknownToolType = 0,
    kBrushToolType,
    kSprayToolType,
    kColorPickerToolType,
    kTextToolType,
    kClipartToolType
} ToolType;

typedef enum {
    kUnknownShakeActionType = 0,
    kStartOverShakeActionType,
    kUndoShakeActionType
} ShakeActionType;

#define kPushAboutToSettingNotification @"PushAboutToSettingNotification"

#define kStartToConnectNotification @"kStartToConnectNotification"
#define kStopConnectingNotification @"kStopConnectingNotification"

#define degreesToRadian(x) (3.14159265358979323846 * x / 180.0)

#define getDocumentPath() ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0])

#define kSelectedTabKey @"kSelectedTabKey"

#define kPointSizeKeyFormat @"kPointSizeKeyFormat%d"

#define kOpacityKeyFormat @"kOpacityKeyFormat%d"

#define kToolKeyFormat @"kToolKeyFormat%d"

#define kColorKeyFormat @"kColorKeyFormat%d"

#define kColorCoordinateKeyFormat @"kColorCoordinateKeyFormat%d"

#define kBrushTool 0
#define kSprayTool 1
#define kTextTool 2

#define kNumberOfTab ((IS_IPAD)?12:5)
#define kTabWidth 64

#define kSelectedTabBackgroundWidth 64
#define kSelectedTabBackgroundHeight 43

#define kScreenWidth  ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)

#define kStatusBarHeight 20
#define kUndoRedoOffsetWhenShowColorTabOnIpad 90 + 20

#define kLauncherAnimationOffsetPortrait 963
#define kLauncherAnimationOffsetLandscape 707

// Color Tab in Bottom of Screen (21, 11, 22, 23)
#define kColorTabOriginX 20
#define kColorTabOriginY 11
#define kColorTabWidth 24
#define kColorTabHeight 23

// Hide Show Button in Bottom of Screen (12, 0, 40, 40)
#define kHideShowButtonInTabArrayOriginX 12
#define kHideShowButtonInTabArrayOriginY 0
#define kHideShowButtonInTabArrayWidth 40
#define kHideShowButtonInTabArrayHeight 40
#define kHideShowButtonInTabArrayIndex ((IS_IPAD) ? 11 : 4)

#define kSliderHeight			22.0
#define kMinPointSize			1.0
#define kMaxPointSize			32.0
//#define kDefaultPointSize		10.0 // warning: 'kDefaultPointSize' macro redefined
#define kEraseButtonWidth		100.0
#define kPickerDisplayConnectionViewDuration 0.12
#define kStatusBarHeight 20

#define kSCStartOverIndex	0
#define kSCUndoIndex		1
#define kSCNoneIndex		2

#define kToolsMinimizedKey @"kToolsMinimizedKey"

@protocol SDSessionDelegate
- (void)editPhotoFinished:(UIImage *)image;
@end

@interface SDUtils : NSObject

+ (NSString*)getCurrentTime;
+ (NSDate*)dateFromString:(NSString *)dateString;
+ (NSString*)stringFromDate:(NSDate *)date;
+ (NSString*)dateDiffFromInterval:(double)ti;
+ (NSString*)dateDiffFromDate:(NSDate *)date;
+ (void)changeSearchBarReturnKeyToReturn:(UISearchBar *)searchBar;
+ (void)removeSearchBarBackground:(UISearchBar *)searchBar;
+ (BOOL)isValidURL:(NSString *)urlString;
+ (int)maxValueSize;
+ (BOOL) isIOS5OrHigher;
+ (BOOL) isIOS6OrHigher;
+ (int) angleFromOrientation:(UIInterfaceOrientation)fromOrientation toOrientation:(UIInterfaceOrientation)toOrientation;
+ (UIImage*) rotateImage:(UIImage *)image withOrientation:(UIImageOrientation)orient;

@end

typedef void (^GSArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^GSResultBlock)(BOOL succeed, NSError *error);
