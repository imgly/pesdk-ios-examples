//
//  GPUImageDesaturation.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageDesaturation : GPUImageFilter
{
    GLint desaturationUniform;
}

// Desaturation ranges from 0.0 to 1.0. With 1.0 meaning full desaturation
@property(readwrite, nonatomic) CGFloat desaturation;

@end
