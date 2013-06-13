//
//  GSUtils.m
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSUtils.h"

@implementation GSUtils

+ (NSString *)generateUniqueId {
    NSMutableString *uniqueId = [NSMutableString stringWithFormat:@"GS%f", [[NSDate date] timeIntervalSince1970]];
    return [uniqueId stringByReplacingOccurrencesOfString:@"." withString:@""];
}

+ (NSString *)generateUniqueIdWithPrefix:(NSString *)prefix {
    NSMutableString *uniqueId = [NSString stringWithFormat:@"%@%f", prefix, [[NSDate date] timeIntervalSince1970]];
    return [uniqueId stringByReplacingOccurrencesOfString:@"." withString:@""];
}

+ (NSString *)getCurrentTime {
    return [self stringFromDate:[NSDate date]];
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)dateDiffFromInterval:(double)ti {
    NSDate *currentDateTime = [NSDate date];
    NSDate *createdDateTime = [NSDate dateWithTimeIntervalSince1970:ti];
    
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:createdDateTime toDate:currentDateTime options:0];
    
    NSString * yearString = ([components year] == 1) ? @"1 year" : [NSString stringWithFormat:@"%d years", [components year]];
    NSString * monthString = ([components month] == 1) ? @"1 month" : [NSString stringWithFormat:@"%d months", [components month]];
    NSString * dayString = ([components day] == 1) ? @"1 day" : [NSString stringWithFormat:@"%d days", [components day]];
    NSString * hourString = ([components hour] == 1) ? @"1 hour" : [NSString stringWithFormat:@"%d hours", [components hour]];
    NSString * minuteString = ([components minute] == 1) ? @"1 minute" : [NSString stringWithFormat:@"%d minutes", [components minute]];
    NSString * secondString = ([components second] == 1) ? @"1 second" : [NSString stringWithFormat:@"%d seconds", [components second]];
    
    if ([components year] > 0 && [components month] == 0) {
        return [NSString stringWithFormat:@"%@ ago", yearString];
    }
    
    if ([components year] > 0 && [components month] > 0) {
        return [NSString stringWithFormat:@"%@ ago", yearString];
    }
    
    if ([components month] > 0 && [components day] == 0) {
        return [NSString stringWithFormat:@"%@ ago", monthString];
    }
    
    if ([components month] > 0 && [components day] > 0) {
        return [NSString stringWithFormat:@"%@ ago", monthString];
    }
    
    if ([components day] > 0 && [components hour] == 0) {
        return [NSString stringWithFormat:@"%@ ago", dayString];
    }
    
    if ([components day] > 0 && [components hour] > 0) {
        return [NSString stringWithFormat:@"%@ ago", dayString];
    }
    
    if ([components hour] > 0 && [components minute] == 0) {
        return [NSString stringWithFormat:@"%@ ago", hourString];
    }
    
    if ([components hour] > 0 && [components minute] > 0) {
        return [NSString stringWithFormat:@"%@ ago", hourString];
    }
    
    if ([components minute] > 0) {
        return [NSString stringWithFormat:@"%@ ago", minuteString];
    }
    
    if ([components second] > 0) {
        return [NSString stringWithFormat:@"%@ ago", secondString];
    }
    
    return @"recently";
}

+ (NSString *)dateDiffFromDate:(NSDate *)date {
    return [GSUtils dateDiffFromInterval:[date timeIntervalSince1970]];
}

+ (void)changeSearchBarReturnKeyToReturn:(UISearchBar *)searchBar {
    for(UIView *subView in searchBar.subviews) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setKeyboardAppearance:UIKeyboardAppearanceAlert];
            [(UITextField *)subView setReturnKeyType:UIReturnKeyDefault];
            [(UITextField *)subView setEnablesReturnKeyAutomatically:NO];
        }
    }
}

+ (void)removeSearchBarBackground:(UISearchBar *)searchBar {
    [searchBar setBackgroundColor:[UIColor clearColor]];
    [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
}

+ (BOOL)isValidURL:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return [NSURLConnection canHandleRequest:request];
}

+ (int)maxValueSize {
    return 10485760;
}

@end
