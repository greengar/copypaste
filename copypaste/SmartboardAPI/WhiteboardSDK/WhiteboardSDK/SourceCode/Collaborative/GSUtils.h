//
//  GSUtils.h
//  Collaborative SDK
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 GreenGar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Enable Crittercism in "Other C Flags" instead
//#define CRITTERCISM 1

#if CRITTERCISM
    #import "Crittercism.h"
#endif

#define VALID_STR(x) (x && [x length] > 0)

#define kDidLogInNotification @"kDidLogInNotification"

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
+ (NSString *)getMacAddress;
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;

@end

typedef void (^GSSingleResultBlock)(id object, NSError *error);
typedef void (^GSArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^GSResultBlock)(BOOL succeed, NSError *error);
typedef void (^GSEmptyBlock)();

typedef enum {
    GSEventTypeChildAdded,    // 0, fired when a new child node is added to a location
    GSEventTypeChildRemoved,  // 1, fired when a child node is removed from a location
    GSEventTypeChildChanged,  // 2, fired when a child node at a location changes
    GSEventTypeChildMoved,    // 3, fired when a child node moves relative to the other child nodes at a location
    GSEventTypeValue          // 4, fired when any data changes at a location and, recursively, any children
} GSEventType;

@interface NSString (alphaOnly)
- (BOOL) isAlphaNumeric;
@end

@implementation NSString (alphaOnly)

- (BOOL) isAlphaNumeric
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound) ? YES : NO;
}

@end