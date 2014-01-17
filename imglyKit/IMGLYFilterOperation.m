//
//  IMGLYFilterOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilterOperation.h"

#import "IMGLYPhotoProcessor_Private.h"

@implementation IMGLYFilterOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _filterType = IMGLYFilterTypeNone;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    GPUImageOutput<GPUImageInput> *filter = [IMGLYFilter filterWithType:self.filterType];
    UIImage *newImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
    return newImage;
}

- (id)copy {
    IMGLYFilterOperation *copy = [[IMGLYFilterOperation alloc] init];
    copy.filterType = _filterType;
    return copy;
}

@end
