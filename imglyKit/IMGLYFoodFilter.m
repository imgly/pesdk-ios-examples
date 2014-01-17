//
//  IMGLYFoodFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFoodFilter.h"

@implementation IMGLYFoodFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        [saturationFilter setSaturation:1.35];
        
        GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:1.1];
        
        [self addFilter:saturationFilter];
        [self addFilter:contrastFilter];
        
        [saturationFilter addTarget:contrastFilter];
        
        [self setInitialFilters:@[saturationFilter]];
        [self setTerminalFilter:contrastFilter];
    }
    
    return self;
}

@end
