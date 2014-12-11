//
//  IMGLYPhotoProcessor.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoProcessor.h"
#import "IMGLYPhotoProcessor_Private.h"

#import "IMGLYOperation.h"
#import "IMGLYProcessingJob.h"

@implementation IMGLYPhotoProcessor

+ (instancetype)sharedPhotoProcessor {
    static IMGLYPhotoProcessor *sharedPhotoProcessor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPhotoProcessor = [[[self class] alloc] init];
    });
    return sharedPhotoProcessor;
}

- (void)performProcessingJob:(IMGLYProcessingJob *)processingJob {
    self.outputImage = [self.inputImage copy];
    for (id <IMGLYOperation> operation in processingJob.operations) {
        self.outputImage = [operation processImage:self.outputImage];
    }
}

- (UIImage *)processImage:(UIImage *)image withType:(IMGLYFilterType)filterType {
    GPUImageOutput <GPUImageInput> *filter = [IMGLYFilter filterWithType:filterType];
    return [self processImage:image withFilter:filter];
}

- (UIImage *)processImage:(UIImage *)image withFilter:(GPUImageOutput <GPUImageInput> *)filter {
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    [picture addTarget:filter];
    [filter useNextFrameForImageCapture];
    [picture processImage];
    return [filter imageFromCurrentFramebufferWithOrientation:image.imageOrientation];
}

@end
