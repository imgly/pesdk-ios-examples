//
//  IMGLYCropOperation.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCropOperation.h"


@implementation IMGLYCropOperation

- (instancetype)initWithRect:(CGRect)rect {
    self = [super init];
    if (self) {
        _rect = rect;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    CGRect bounds = CGRectMake(self.rect.origin.x * image.size.width,
                               self.rect.origin.y * image.size.height,
                               self.rect.size.width * image.size.width,
                               self.rect.size.height * image.size.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (id)copy {
    IMGLYCropOperation *copy = [[IMGLYCropOperation alloc] init];
    copy.rect = _rect;
    return copy;
}

@end
