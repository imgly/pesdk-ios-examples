//
//  imglyKit.h
//  imglyKit
//
//  Created by Sascha Schwabbauer on 29/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double imglyKitVersionNumber;
FOUNDATION_EXPORT const unsigned char imglyKitVersionString[];

#import <imglyKit/LUTToNSDataConverter.h>

// Bitmask for allowed orientation types
typedef NS_OPTIONS(NSInteger, IMGLYOrientationAction) {
    IMGLYOrientationActionRotateLeft = 1 << 0,
    IMGLYOrientationActionRotateRight = 1 << 1,
    IMGLYOrientationActionFlipHorizontally = 1 << 2,
    IMGLYOrientationActionFlipVertically = 1 << 3
};

// Bitmask for focus actions
typedef NS_OPTIONS(NSInteger, IMGLYFocusAction) {
    IMGLYFocusActionOff = 1 << 0,
    IMGLYFocusActionLinear = 1 << 1,
    IMGLYFocusActionRadial = 1 << 2
};

// Bitmask for crop actions
typedef NS_OPTIONS(NSInteger, IMGLYCropAction) {
    IMGLYCropActionFree = 1 << 0,
    IMGLYCropActionOneToOne = 1 << 1,
    IMGLYCropActionFourToThree = 1 << 2,
    IMGLYCropActionSixteenToNine = 1 << 3
};
