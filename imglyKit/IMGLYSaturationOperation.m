//
//  IMGLYSaturationOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYSaturationOperation.h"

#import "IMGLYFilter.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYSaturationFilter.h"

@implementation IMGLYSaturationOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _saturation = 1;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    IMGLYSaturationFilter *filter = (IMGLYSaturationFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeSaturation];
    filter.saturation = self.saturation;
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
}

- (id)copy {
    IMGLYSaturationOperation *copy = [[IMGLYSaturationOperation alloc] init];
    copy.saturation = _saturation;
    return copy;
}


@end
