//
//  IMGLYBrightnessOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYBrightnessOperation.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYBrightnessFilter.h"

@implementation IMGLYBrightnessOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _brightness = 0.0;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    IMGLYBrightnessFilter *filter = (IMGLYBrightnessFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeBrightness];
    filter.brightness = self.brightness;
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
}

- (id)copy {
    IMGLYBrightnessOperation *copy = [[IMGLYBrightnessOperation alloc] init];
    copy.brightness = _brightness;
    return copy;
}

@end
