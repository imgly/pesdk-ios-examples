//
//  GPUImageColorAddGlow.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 19.11.12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//
 

#import "GPUImageFilter.h"

/** Performs a vignetting effect, fading out the image at the edges
 */
@interface GPUImageColorAddGlow : GPUImageFilter
{
    GLint colorToAddUniform, glowStartUniform, glowEndUniform;
}

// The normalized distance from the center where the vignette effect starts. Default of 0.5.
@property (nonatomic, readwrite) CGFloat glowStart;

// The normalized distance from the center where the vignette effect ends. Default of 0.75.
@property (nonatomic, readwrite) CGFloat glowEnd;

- (void)setColorToAddRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
@end
