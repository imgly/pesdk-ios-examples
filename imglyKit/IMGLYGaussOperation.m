//
//  IMGLYGaussOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 13.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYGaussOperation.h"

#import "IMGLYGaussFilter.h"
#import "IMGLYFilter.h"
#import "IMGLYPhotoProcessor_Private.h"

@implementation IMGLYGaussOperation

- (UIImage *)processImage:(UIImage *)image {
    IMGLYGaussFilter *filter = (IMGLYGaussFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeGauss];
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
}

- (id)copy {
    id copy = [[[self class] alloc] init];
    return copy;
}

@end
