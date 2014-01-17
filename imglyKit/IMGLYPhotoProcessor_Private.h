//
//  IMGLYPhotoProcessor_Private.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYPhotoProcessor.h"

#import <NEGPUImage/GPUImage.h>

@interface IMGLYPhotoProcessor ()

@property (nonatomic, strong) GPUImageOutput <GPUImageInput> *currentFilter;

- (UIImage *)processImage:(UIImage *)image withType:(IMGLYFilterType)filterType;

- (UIImage *)processImage:(UIImage *)image withFilter:(GPUImageOutput <GPUImageInput> *)filter;

@end
