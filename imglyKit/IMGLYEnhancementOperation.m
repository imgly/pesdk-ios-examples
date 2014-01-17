//
// IMGLYEnhancementOperation.m
// imglyKit
// 
// Created by Carsten Przyluczky on 21.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import "IMGLYEnhancementOperation.h"
#import <CoreImage/CoreImage.h>

@implementation IMGLYEnhancementOperation

- (UIImage *)processImage:(UIImage *)image {
    CIImage* ciImage = [[CIImage alloc] initWithCGImage:image.CGImage];

    /// Get the filters and apply them to the image
    NSArray* filters = [ciImage autoAdjustmentFiltersWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kCIImageAutoAdjustRedEye]];
    for (CIFilter* filter in filters) {
        [filter setValue:ciImage forKey:kCIInputImageKey];
        ciImage = filter.outputImage;
    }

    /// Create the corrected image
    CIContext* ctx = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [ctx createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage* final = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return final;
}

- (id)copy {
    IMGLYEnhancementOperation *copy = [[IMGLYEnhancementOperation alloc] init];
    return copy;
}

@end
