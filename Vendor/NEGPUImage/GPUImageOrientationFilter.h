//
//  GPUImageOrientationFilter.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 21.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageOrientationFilter : GPUImageFilter
{
    GLint flipVerticalUniform, flipHorizontalUniform;
}

// 0 means no flip, 1 means flip
@property(readwrite, nonatomic, setter = setFlipHorizontal:) NSInteger flipHorizontal;
@property(readwrite, nonatomic, setter = setFlipVertical:) NSInteger flipVertical;

@end
