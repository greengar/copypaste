//
//  GSSUtils.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Firebase/Firebase.h>

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

@interface GSUtils : NSObject

+ (NSString *) getCurrentTime;
+ (NSDate *) dateFromString:(NSString *)dateString;
+ (NSString *) stringFromDate:(NSDate *)date;
+ (NSString*) dateDiffFromInterval:(double)ti;
+ (NSString*) dateDiffFromDate:(NSDate *)date;

@end

typedef void (^GSArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^GSResultBlock)(BOOL succeed, NSError *error);
