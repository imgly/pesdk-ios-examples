//
//  IMGLYTiltShiftOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 05.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYTiltShiftOperation.h"

#import "IMGLYBoxTiltShiftFilter.h"
#import "IMGLYRadialTiltShiftFilter.h"
#import "IMGLYFilter.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYProcessingJob.h"

@interface IMGLYTiltShiftOperation ()

@property (nonatomic, strong) UIImage *image;

@end

#pragma mark -

@implementation IMGLYTiltShiftOperation

- (UIImage *)processImage:(UIImage *)image {
    self.image = image;

    if (self.blurredImage == nil) {
        self.blurredImage = [self generateBlurredImage];
    }

    UIImage *processedImage;
    if (self.tiltShiftMode == IMGLYTiltShiftModeBox) {
        processedImage = [self processImageWithBoxFilter];
    }
    else {
        processedImage = [self processImageWithRadialFilter];
    }

    return processedImage;
}

- (UIImage *)generateBlurredImage {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.image];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

- (UIImage *)processImageWithBoxFilter {
    IMGLYBoxTiltShiftFilter *filter = (IMGLYBoxTiltShiftFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeBoxTiltShift];
    filter.controlPoint1 = self.controlPoint1;
    filter.controlPoint2 = self.controlPoint2;
    filter.scaleVector = self.scaleVector;
    return [self processImageWithFilter:filter];
}

- (UIImage *)processImageWithRadialFilter {
    IMGLYRadialTiltShiftFilter *filter = (IMGLYRadialTiltShiftFilter *)[IMGLYFilter filterWithType:IMGLYFilterTypeRadialTiltShift];
    filter.controlPoint1 = self.controlPoint1;
    filter.controlPoint2 = self.controlPoint2;
    filter.scaleVector = self.scaleVector;
    return [self processImageWithFilter:filter];
}

- (UIImage *)processImageWithFilter:(GPUImageOutput <GPUImageInput> *)filter {
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:self.blurredImage];
    [picture addTarget:filter];
    [picture processImage];
    return [[IMGLYPhotoProcessor sharedPhotoProcessor] processImage:self.image withFilter:filter];
}


- (id)copy {
    IMGLYTiltShiftOperation *copy = [[IMGLYTiltShiftOperation alloc] init];
    copy.tiltShiftMode = _tiltShiftMode;
    copy.controlPoint1 = _controlPoint1;
    copy.controlPoint2 = _controlPoint2;
    copy.scaleVector = _scaleVector;
    return copy;
}


@end
