//
//  IMGLYOrientationFilter.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 20.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NEGPUImage/GPUImage.h>

typedef NS_ENUM(NSInteger, IMGLYRotationAngle) {
    IMGLYRotationAngle0,
    IMGLYRotationAngle90,
    IMGLYRotationAngle180,
    IMGLYRotationAngle270
};

@interface IMGLYOrientationFilter : GPUImageOrientationFilter

@property (nonatomic, assign) IMGLYRotationAngle rotationAngle;

@end
