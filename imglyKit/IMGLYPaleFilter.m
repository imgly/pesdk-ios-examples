//
//  IMGLYPaleFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYPaleFilter.h"

@implementation IMGLYPaleFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(152.0 / 255.0, 175.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(188.0 / 255.0, 218.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0, 39.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(196.0 / 255.0, 192.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1,231.0 / 255.0)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 72.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(209.0 / 255.0, 1)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                          nil]];
        
        GPUImageToneCurveFilter* contrastCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)contrastCurveFilter  setRGBControlPoints:[NSArray arrayWithObjects:
                                                                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(87.0 / 255.0, 104.0 / 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(153.0 / 255.0, 228.0 / 255.0)],
                                                                              [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                              nil]];
        
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastCurveFilter];
        
        // build chain
        [toneCurveFilter addTarget:contrastCurveFilter];
        
        // register chain
        [self setInitialFilters:@[ toneCurveFilter ]];
        [self setTerminalFilter:contrastCurveFilter];
    }
    
    return self;
}

@end
