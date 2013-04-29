//
//  Smartboard.h
//  SmartboardSDK
//
//  Created by Hector Zhao on 4/29/13.
//  Copyright (c) 2013 Greengar Studios. All rights reserved.
//

#import "GSSession.h"
#import "GSUser.h"
#import "GSObject.h"

#define IS_IPAD      (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
#define IS_IPAD1    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale == 1.0) && (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
#define IS_IPAD2    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale == 1.0) &&([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
#define IS_IPAD3    ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) && ([UIScreen mainScreen].scale != 1.0))

#define IS_IPHONE5  ([[UIScreen mainScreen] bounds].size.height == 568)
#define DEFAULT_FONT_SIZE(f) [UIFont fontWithName:@"Heiti SC" size:f];

#ifdef DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#       define DLog(...)
#endif

