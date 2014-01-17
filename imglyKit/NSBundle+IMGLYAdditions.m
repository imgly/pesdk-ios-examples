//
//  NSBundle+IMGLYAdditions.m
//  imglyKit
//
//  Created by Manuel Binna on 12.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "NSBundle+IMGLYAdditions.h"

@implementation NSBundle (IMGLYAdditions)

+ (NSBundle *)imgly_frameworkBundle {
    static NSBundle *imglyFrameworkBundle;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString *frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:IMGLYBundleName];
        imglyFrameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return imglyFrameworkBundle;
}

@end

NSString *const IMGLYBundleName = @"imglyKit.bundle";
