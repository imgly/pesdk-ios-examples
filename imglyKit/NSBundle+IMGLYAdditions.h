//
//  NSBundle+IMGLYAdditions.h
//  imglyKit
//
//  Created by Manuel Binna on 12.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Adds framework-related methods to `NSBundle`.
 */
@interface NSBundle (IMGLYAdditions)

/**
 * Returns the `NSBundle` obyject that contains the resources of the framework.
 *
 * @return The `NSBundle` object that contains the resources of the framework, or `nil` if a bundle object could not be 
 *         created.
 */
+ (NSBundle *)imgly_frameworkBundle;

@end

/**
 * The name of the bundle that contains the resources of the framework.
 */
extern NSString *const IMGLYBundleName;
