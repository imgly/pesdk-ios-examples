//
//  GPUImageOneColorGrayFilter.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 30.10.12.
//  Copyright (c) 2012 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"


@interface GPUImageOneColorGrayFilter : GPUImageFilter
{
    GLint colorToReplaceUniform, thresholdSensitivityUniform, smoothingUniform;
}
@property(readwrite, nonatomic) GLfloat smoothing;
@property(readwrite, nonatomic) GLfloat thresholdSensitivity;
/** The color to be replaced is specified using individual red, green, and blue components (normalized to 1.0).
 
 The default is green: (0.0, 1.0, 0.0).
 
 @param redComponent Red component of color to be replaced
 @param greenComponent Green component of color to be replaced
 @param blueComponent Blue component of color to be replaced
 */
- (void)setColorToReplaceRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent;
@end
