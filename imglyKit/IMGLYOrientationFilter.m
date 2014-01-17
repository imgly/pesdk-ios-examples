//
//  IMGLYOrientationFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 20.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOrientationFilter.h"

@implementation IMGLYOrientationFilter 

- (void)setRotationAngle:(IMGLYRotationAngle)rotationAngle {
    switch (rotationAngle) {
        case IMGLYRotationAngle0:
            [self setInputRotation:kGPUImageNoRotation atIndex:0];
            break;
        case IMGLYRotationAngle90:
            [self setInputRotation:kGPUImageRotateRight atIndex:0];
            break;
        case IMGLYRotationAngle180:
            [self setInputRotation:kGPUImageRotate180 atIndex:0];
            break;
        case IMGLYRotationAngle270:
            [self setInputRotation:kGPUImageRotateLeft atIndex:0];
            break;
    }
}

@end
