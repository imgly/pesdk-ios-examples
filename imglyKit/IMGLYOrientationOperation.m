//
//  IMGLYRotateOperation.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOrientationOperation.h"

#import "IMGLYFilter.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "UIImage+IMGLYKitAdditions.h"

@implementation IMGLYOrientationOperation
{
    BOOL _flipVertical;
    BOOL _flipHorizontal;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rotationAngle = IMGLYRotationAngle0;
        _flipHorizontal = NO;
        _flipVertical = NO;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    IMGLYOrientationFilter *filter = (IMGLYOrientationFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeOrientation];

    if (_flipHorizontal) {
        const NSInteger IMGLYFlipHorizontal = 1;
        filter.flipHorizontal = IMGLYFlipHorizontal;
    }

    if (_flipVertical) {
        const NSInteger IMGLYFlipVertical = 1;
        filter.flipVertical = IMGLYFlipVertical;
    }

    filter.rotationAngle = self.rotationAngle;

    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:image withFilter:filter];
}

- (void)rotateRight {
    switch (self.rotationAngle) {
        case IMGLYRotationAngle0:
            self.rotationAngle = IMGLYRotationAngle90;
            break;
        case IMGLYRotationAngle90:
            self.rotationAngle = IMGLYRotationAngle180;
            break;
        case IMGLYRotationAngle180:
            self.rotationAngle = IMGLYRotationAngle270;
            break;
        case IMGLYRotationAngle270:
            self.rotationAngle = IMGLYRotationAngle0;
            break;
    }
}

- (void)rotateLeft {
    switch (self.rotationAngle) {
        case IMGLYRotationAngle0:
            self.rotationAngle = IMGLYRotationAngle270;
            break;
        case IMGLYRotationAngle90:
            self.rotationAngle = IMGLYRotationAngle0;
            break;
        case IMGLYRotationAngle180:
            self.rotationAngle = IMGLYRotationAngle90;
            break;
        case IMGLYRotationAngle270:
            self.rotationAngle = IMGLYRotationAngle180;
            break;
    }
}

- (void)flipHorizontal {
    if (self.rotationAngle == IMGLYRotationAngle0 || self.rotationAngle == IMGLYRotationAngle180) {
        _flipHorizontal = !_flipHorizontal;
    } else {
        _flipVertical = !_flipVertical;
    }
}

- (void)flipVertical {
    if (self.rotationAngle == IMGLYRotationAngle0 || self.rotationAngle == IMGLYRotationAngle180) {
        _flipVertical = !_flipVertical;
    } else {
        _flipHorizontal = !_flipHorizontal;
    }
}

- (id)copy {
    IMGLYOrientationOperation *copy = [[IMGLYOrientationOperation alloc] init];
    if (_flipHorizontal) {
        [copy flipHorizontal];
    }
    
    if (_flipVertical) {
        [copy flipVertical];
    }
    
    copy.rotationAngle = self.rotationAngle;
    return copy;
}


@end
