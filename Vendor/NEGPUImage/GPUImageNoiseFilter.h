//
//  GPUImageNoiseFilter.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 04.09.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface GPUImageNoiseFilter : GPUImageTwoInputFilter
{
    GLint intensityUniform;
}

// intensity ranges from 0.0 to 1.0, with 0.0 as no noise and 1.0 full noise
@property(nonatomic, readwrite) CGFloat intensity;

@end

