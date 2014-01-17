//
//  IMGLYNoiseOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 04.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYNoiseOperation.h"

#import "IMGLYCropOperation.h"
#import "IMGLYFilter.h"
#import "IMGLYNoiseFilter.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "UIImage+IMGLYKitAdditions.h"

@implementation IMGLYNoiseOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        _intensity = 0;
    }
    return self;
}

- (UIImage *)processImage:(UIImage *)image {
    if (self.noiseImage == nil) {
        float biggerSide = image.size.width;
        if (image.size.height > biggerSide) {
            biggerSide = image.size.height;
        }
        if(biggerSide <= 512.0) {
            self.noiseImage = [UIImage imgly_imageNamed:@"noise512"];
        }
        else if(biggerSide <= 1024.0) {
            self.noiseImage = [UIImage imgly_imageNamed:@"noise1024"];
        }
        else if(biggerSide <= 2048.0) {
            self.noiseImage = [UIImage imgly_imageNamed:@"noise2048"];
        }
        else if(biggerSide <= 4096.0) {
            self.noiseImage = [UIImage imgly_imageNamed:@"noise4096"];
        }
    }
    
    IMGLYNoiseFilter *filter = (IMGLYNoiseFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeNoise];
    filter.intensity = self.intensity;

    IMGLYCropOperation *cropOperation = [[IMGLYCropOperation alloc] initWithRect:CGRectMake(
            0.0,
            0.0,
            image.size.width / self.noiseImage.size.width,
            image.size.height / self.noiseImage.size.height
    )];

    UIImage *cropedNoiseImage = [cropOperation processImage:self.noiseImage];

    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    [picture addTarget:filter];
    [picture processImage];
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:cropedNoiseImage withFilter:filter];
}

- (id)copy {
    IMGLYNoiseOperation *copy = [[IMGLYNoiseOperation alloc] init];
    copy.intensity = _intensity;
    return copy;
}

@end
