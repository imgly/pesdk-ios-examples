//
//  GPUImageSoftColorOverlay.h
//  GPUImage
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 Brad Larson. All rights reserved.
//

#import "GPUImageFilter.h"

@interface GPUImageSoftColorOverlay : GPUImageFilter {
    GLint overlayColorUniform;
}

- (void) setOverlayColorRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;


@end
