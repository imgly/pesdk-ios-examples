//
//  IMGLYDeviceDetector.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 01.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface IMGLYDeviceDetector : NSObject

+ (BOOL) isRunningOn3GS;
+ (BOOL) isRunningOn4Inch;
+ (BOOL) isRunningOn4S;

@end
