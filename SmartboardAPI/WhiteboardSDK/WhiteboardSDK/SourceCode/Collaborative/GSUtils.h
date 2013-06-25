//
//  GSUtils.h
//  CollaborativeSDK
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

@protocol GSSessionDelegate
- (void)didFinishAuthentication:(NSError *)error;
@end

@protocol GSMessageDelegate
- (void)didReceiveMessage:(NSDictionary *)dictInfo;
@end

@interface GSUtils : NSObject

+ (NSString*)generateUniqueId;
+ (NSString *)generateUniqueIdWithPrefix:(NSString *)prefix;
+ (NSString*)getCurrentTime;
+ (NSDate*)dateFromString:(NSString *)dateString;
+ (NSString*)stringFromDate:(NSDate *)date;
+ (NSString*)dateDiffFromInterval:(double)ti;
+ (NSString*)dateDiffFromDate:(NSDate *)date;
+ (void)changeSearchBarReturnKeyToReturn:(UISearchBar *)searchBar;
+ (void)removeSearchBarBackground:(UISearchBar *)searchBar;
+ (BOOL)isValidURL:(NSString *)urlString;
+ (int)maxValueSize;
@end

typedef void (^GSSingleResultBlock)(id object, NSError *error);
typedef void (^GSArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^GSResultBlock)(BOOL succeed, NSError *error);
typedef void (^GSEmptyBlock)();
