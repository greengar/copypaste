//
//  GSSUtils.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSUtils : NSObject

+ (NSString *) getCurrentTime;
+ (NSDate *) dateFromString:(NSString *)dateString;
+ (NSString *) stringFromDate:(NSDate *)date;
+ (NSString*) dateDiffFromInterval:(double)ti;
+ (NSString*) dateDiffFromDate:(NSDate *)date;

@end

typedef void (^GSArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^GSResultBlock)(NSError *error);
