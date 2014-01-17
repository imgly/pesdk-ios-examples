//
//  IMGLYGlamFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYGlamFilter.h"

@implementation IMGLYGlamFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageGrayscaleFilter *grayFilter = [[GPUImageGrayscaleFilter alloc] init];
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        
        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:(1.6)];
        
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(94.0 / 255.0, 74.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(181.0 / 255.0, 205.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0 , 0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(102.0 / 255.0, 73.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(227.0 / 255.0, 213.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                          nil]];
        
        // add filters
        [self addFilter:grayFilter];
        [self addFilter:contrastFilter];
        [self addFilter:toneCurveFilter];
        
        // build chain
        [grayFilter addTarget:contrastFilter];
        [contrastFilter addTarget:toneCurveFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:grayFilter]];
        [self setTerminalFilter:toneCurveFilter];
    }
    
    return self;
}

@end
