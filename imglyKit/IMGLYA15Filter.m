//
//  IMGLYA15Filter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYA15Filter.h"

@implementation IMGLYA15Filter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:(1-0.37)];
        
        GPUImageBrightnessFilter* brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        [brightnessFilter setBrightness:0.12];
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 38.0 / 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(94.0 / 255.0, 94.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(148.0 / 255.0, 142.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(175.0 / 255.0, 187.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0, 0 )],
                                                                           [NSValue valueWithCGPoint:CGPointMake(77.0 / 255.0, 53.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(171.0 / 255.0, 190.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0 , 10.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(48.0 / 255.0, 85.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(174.0 / 255.0, 228.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                          nil]];
        
        // add filters
        [self addFilter:contrastFilter];
        [self addFilter:brightnessFilter];
        [self addFilter:toneCurveFilter];
        
        // build chain
        [contrastFilter addTarget:brightnessFilter];
        [brightnessFilter addTarget:toneCurveFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:contrastFilter]];
        [self setTerminalFilter:toneCurveFilter];    

    }
    
    return self;
}

@end
