//
//  GSSUtils.h
//  copypaste
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSSUtils : NSObject

+ (NSString *) getCurrentTime;
+ (NSDate *) dateFromString:(NSString *)dateString;
+ (NSString*) dateDiffFromInterval:(double)ti;
+ (NSString*) dateDiffFromDate:(NSDate *)date;

@end
