//
//  IMGLYPhotoProcessor.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

@class IMGLYProcessingJob;

/**
 Applies a filter on a given image and renders the image.
 */
@interface IMGLYPhotoProcessor : NSObject

/**
 @return The singleton instance.
 */
+ (instancetype)sharedPhotoProcessor;

/**
 The image to be processed.
 */
@property (nonatomic, strong) UIImage *inputImage;

/**
 The processed image.
 */
@property (nonatomic, strong) UIImage *outputImage;

/**
 The filter that is applied to the input image.
 */
@property (nonatomic, assign) IMGLYFilterType filterType;

/**
 Performs the operations in the processing job.

 @param processingJob Contains the operations that should be performed.
 */
- (void)performProcessingJob:(IMGLYProcessingJob *)processingJob;

@end
