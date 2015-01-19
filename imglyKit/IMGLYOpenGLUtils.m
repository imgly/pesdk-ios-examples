//
//  IMGLYOpenGLUtils.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 04.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOpenGLUtils.h"

#import <NEGPUImage/GPUImage.h>

@implementation IMGLYOpenGLUtils

+ (GLint)maximumTextureSizeForThisDevice {
    return 1024; //[GPUImageOpenGLESContext maximumTextureSizeForThisDevice];
}

@end
