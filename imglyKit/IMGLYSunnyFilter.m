//
//  IMGLYSunnyFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYSunnyFilter.h"

@implementation IMGLYSunnyFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(62.0 / 255.0, 82.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(141.0 / 255.0, 154.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0, 39.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(56.0 / 255.0, 96.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(192.0 / 255.0, 176.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(174.0 / 255.0, 99.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 235.0 / 255.0)],
                                                                          nil]];
        
        GPUImageToneCurveFilter* contrastCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)contrastCurveFilter  setRGBControlPoints:[NSArray arrayWithObjects:
                                                                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(55.0 / 255.0, 20 / 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(158.0 / 255.0, 191.0 / 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                              nil]];
        
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastCurveFilter];
        
        // build chain
        [toneCurveFilter addTarget:contrastCurveFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:toneCurveFilter]];
        [self setTerminalFilter:contrastCurveFilter];
    }
    
    return self;
}

@end
