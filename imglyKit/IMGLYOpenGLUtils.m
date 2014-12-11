//
//  IMGLYOpenGLUtils.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 04.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOpenGLUtils.h"

#import <NEGPUImage/GPUImage.h>
#import <OpenGLES/EAGLDrawable.h>
#import <AVFoundation/AVFoundation.h>

@implementation IMGLYOpenGLUtils

+ (GLint)maximumTextureSizeForThisDevice {
    GLint maxTextureSize;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
    return maxTextureSize;
}
@end
