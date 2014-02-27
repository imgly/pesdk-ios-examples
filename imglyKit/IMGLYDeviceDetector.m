//
//  IMGLYDeviceDetector.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 01.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYDeviceDetector.h"

#import <sys/utsname.h>

#define IPHONE_3GS_NAMESTRING @"iPhone2,1"
#define IPHONE_4S_NAMESTRING @"iPhone4,1"

@implementation IMGLYDeviceDetector

+ (NSString*) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (BOOL) isRunningOn3GS
{
    NSString* machineName = [self machineName];
    return [machineName isEqualToString:IPHONE_3GS_NAMESTRING];
}

+ (BOOL) isRunningOn4Inch
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    return (mainScreen.bounds.size.height >= 568);
}

+ (BOOL) isRunningOn4S
{
    NSString* machineName = [self machineName];
    return [machineName isEqualToString:IPHONE_4S_NAMESTRING];
}


@end
