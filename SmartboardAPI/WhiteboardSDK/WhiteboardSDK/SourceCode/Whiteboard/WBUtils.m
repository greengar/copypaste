//
//  WBUtils.m
//  WhiteboardSDK
//
//  Created by Hector Zhao on 4/24/13.
//  Copyright (c) 2013 Greengar. All rights reserved.
//

#import "WBUtils.h"

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
    return 10485760;
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

@end
