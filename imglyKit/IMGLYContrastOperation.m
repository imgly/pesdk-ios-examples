//
//  IMGLYContrastOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYContrastOperation.h"

#import "IMGLYContrastFilter.h"
#import "IMGLYFilter.h"
#import "IMGLYPhotoProcessor_Private.h"

@implementation IMGLYContrastOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _contrast = 1;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    IMGLYContrastFilter *filter = (IMGLYContrastFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeContrast];
    filter.contrast = self.contrast;
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
}

- (id)copy {
    IMGLYContrastOperation *copy = [[IMGLYContrastOperation alloc] init];
    copy.contrast = _contrast;
    return copy;
}

@end
