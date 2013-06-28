//
//  WBUtils.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBUtils.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation WBUtils

+ (int)getBuildVersion {
    /* return 1; 1 is for the OpenGL-only build */
    return 2;
}

+ (NSString *)generateUniqueId {
    NSMutableString *uniqueId = [NSMutableString stringWithFormat:@"WB%f", [[NSDate date] timeIntervalSince1970]];
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
    return [WBUtils dateDiffFromInterval:[date timeIntervalSince1970]];
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
    return 8388608;
}

+ (BOOL) isIOS5OrHigher {
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (BOOL) isIOS6OrHigher {
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }
    return NO;
}

+ (int) angleFromOrientation:(UIInterfaceOrientation)fromOrientation toOrientation:(UIInterfaceOrientation)toOrientation {
    switch (fromOrientation) {
        case UIDeviceOrientationPortrait:
            switch (toOrientation) {
                case UIDeviceOrientationPortrait:
                    return 0;
                case UIDeviceOrientationLandscapeLeft:
                    return -90;
                case UIDeviceOrientationPortraitUpsideDown:
                    return 180;
                case UIDeviceOrientationLandscapeRight:
                    return 90;
                default:
                    return 0;
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            switch (toOrientation) {
                case UIDeviceOrientationPortrait:
                    return 180;
                case UIDeviceOrientationLandscapeLeft:
                    return 90;
                case UIDeviceOrientationPortraitUpsideDown:
                    return 0;
                case UIDeviceOrientationLandscapeRight:
                    return -90;
                default:
                    return 0;
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
            switch (toOrientation) {
                case UIDeviceOrientationPortrait:
                    return 90;
                case UIDeviceOrientationLandscapeLeft:
                    return 0;
                case UIDeviceOrientationPortraitUpsideDown:
                    return -90;
                case UIDeviceOrientationLandscapeRight:
                    return 180;
                default:
                    return 0;
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            switch (toOrientation) {
                case UIDeviceOrientationPortrait:
                    return -90;
                case UIDeviceOrientationLandscapeLeft:
                    return 180;
                case UIDeviceOrientationPortraitUpsideDown:
                    return 90;
                case UIDeviceOrientationLandscapeRight:
                    return 0;
                default:
                    return 0;
            }
            break;
        default:
            break;
    }
    return 0;
}

+ (CGRect) swapWidthAndHeight:(CGRect)rect {
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

+ (UIImage*) rotateImage:(UIImage *)image withOrientation:(UIImageOrientation)orient {
	
	DLog(@"Rotating image with width:%f height:%f", image.size.width, image.size.height);
	
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = image.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			assert(false);
			return nil;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			bnds = [self swapWidthAndHeight:bnds];
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			bnds = [self swapWidthAndHeight:bnds];
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			bnds = [self swapWidthAndHeight:bnds];
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			bnds = [self swapWidthAndHeight:bnds];
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}

+ (CABasicAnimation *)bounceAnimationFrom:(NSValue *)from
                                       to:(NSValue *)to
                               forKeyPath:(NSString *)keypath
                             withDuration:(CFTimeInterval)duration
                                 delegate:(id)delegate {
    CABasicAnimation * boundAnim = [CABasicAnimation animationWithKeyPath:keypath];
    [boundAnim setFromValue:from];
    [boundAnim setToValue:to];
    [boundAnim setDuration:duration];
    [boundAnim setDelegate:delegate];
    [boundAnim setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :1.8 :0.8 :0.8]];
    return  boundAnim;
}

+ (NSObject *)getThingsFromClipboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSArray *passboardTypes = [pasteboard pasteboardTypes];
    if ([passboardTypes count] > 0) {
        NSString *firstDataType = [passboardTypes objectAtIndex:0];
        NSData *data = [pasteboard dataForPasteboardType:firstDataType];
        DLog(@"Data type: %@", firstDataType);
        
        if (([firstDataType compare:@"public.text" options:NSCaseInsensitiveSearch] == NSOrderedSame) // Normal text
            || ([firstDataType compare:@"public.utf8-plain-text" options:NSCaseInsensitiveSearch] == NSOrderedSame) // UTF8 text
            || ([firstDataType compare:@"com.agilebits.onepassword" options:NSCaseInsensitiveSearch] == NSOrderedSame))  { // 1Password
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            return string;
            
        } else if (([firstDataType compare:@"public.jpeg" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                   || ([firstDataType compare:@"public.jpg" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                   || ([firstDataType compare:@"public.png" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
            UIImage *image = [UIImage imageWithData:data];
            return image;
            
        } else if ([firstDataType compare:@"com.apple.mobileslideshow.asset-object-id-uri" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            UIImage *image = pasteboard.image;
            return image;
            
        } else {
            @try { // Try to parse all other kinds of object, catch the exception and return nil if not parsable
                NSString *string = [NSString stringWithUTF8String:[data bytes]];
                return string;
            }
            @catch (NSException *exception) {
                DLog(@"Object from clipboard is not parsable");
                return nil;
            }
        }
    }
    return nil;
}

+ (NSString *)getBaseDocumentFolder {
    NSString *baseDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES) objectAtIndex:0];
    return [baseDir stringByAppendingPathComponent:@"Whiteboard/"];
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
    
    // Befor going any further...
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

@end
