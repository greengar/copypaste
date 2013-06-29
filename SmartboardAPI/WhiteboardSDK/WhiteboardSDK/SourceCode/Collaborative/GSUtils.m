//
//  GSUtils.m
//  CollaborativeSDK
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "GSUtils.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

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

+ (NSString *)getMacAddress {
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Before going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

// via http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
