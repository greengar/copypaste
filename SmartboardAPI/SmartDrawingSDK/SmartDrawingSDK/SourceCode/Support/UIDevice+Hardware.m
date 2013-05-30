//
//  UIDevice+Hardware.m
// SmartDrawingSDK
//
//  Created by Elliot on 7/27/10.
//  Copyright 2010 GreenGar Studios. All rights reserved.
//

#import "UIDevice+Hardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (Hardware)

/*
 Platforms
 iPhone1,1 -> iPhone 1G
 iPhone1,2 -> iPhone 3G 
 iPod1,1   -> iPod touch 1G 
 iPod2,1   -> iPod touch 2G 
 
 iPhone Simulator == i386
 iPhone == iPhone1,1
 3G iPhone == iPhone1,2
 3GS iPhone == iPhone2,1
 1st Gen iPod == iPod1,1
 2nd Gen iPod == iPod2,1
 1st Gen iPad == iPad1,1
 iPhone 4 == iPhone3,1
 I imagine the iPod Touch 4 will be == iPod3,1
 and the 2011 next generation iPad will be == iPad2,1
 
 */

- (NSString *) platform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return platform;
}

@end
