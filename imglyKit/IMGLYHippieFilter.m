//
//  IMGLYHippieFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYHippieFilter.h"

@implementation IMGLYHippieFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageBrightnessFilter* brightnessFiter = [[GPUImageBrightnessFilter alloc] init];
        [brightnessFiter setBrightness:0.18];
        
        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:1.3];
        
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 145.0 / 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(41.0 / 255.0, 136.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(204.0 / 255.0, 180.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(255.0 / 255.0, 255.0/ 255.0)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(100.0 / 255.0, 111.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(162.0 / 255.0, 202.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(255.0 / 255.0, 255.0/ 255.0)],
                                                                           nil]];
        
        GPUImageToneCurveFilter* contrastCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)contrastCurveFilter  setRGBControlPoints:[NSArray arrayWithObjects:
                                                                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(110.0 / 255.0, 121.0/ 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(158.0 / 255.0, 188.0/ 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                              nil]];
        
        
        // add filters
        [self addFilter:contrastCurveFilter];
        [self addFilter:toneCurveFilter];
        
        // build chain
        [contrastCurveFilter addTarget:toneCurveFilter];
        
        // register chain
        [self setInitialFilters:@[ contrastCurveFilter ]];
        [self setTerminalFilter:toneCurveFilter];
    }
    
    return self;
}

@end
