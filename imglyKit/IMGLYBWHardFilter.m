//
//  IMGLYBWHard.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYBWHardFilter.h"

@implementation IMGLYBWHardFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageGrayscaleFilter* grayScaleFilter = [[GPUImageGrayscaleFilter alloc] init];
        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:(1.5)];
        
        // add filters
        [self addFilter:grayScaleFilter];
        [self addFilter:contrastFilter];
        
        // build chain
        [grayScaleFilter addTarget:contrastFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:grayScaleFilter]];
        [self setTerminalFilter:contrastFilter];
    }
    
    return self;
}

@end
