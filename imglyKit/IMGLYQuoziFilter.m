//
//  IMGLYQuoziFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYQuoziFilter.h"

@implementation IMGLYQuoziFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageDesaturation* desaturation = [[GPUImageDesaturation alloc] init];
        desaturation.desaturation = 0.65;
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 50.0 / 255)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(40.0 / 255.0, 78.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(118.0 / 255.0, 170.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(181.0 / 255.0, 211.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1, 231.0 / 255.0)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0.0, 27.0 / 255)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(28.0 / 255.0, 45.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(109.0 / 255.0, 157.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(157.0 / 255.0, 195.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(179.0 / 255.0, 208.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(206.0 / 255.0, 212.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1, 240.0 / 255)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 50.0 / 255)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(12.0 / 255.0, 55.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(46.0 / 255.0, 103.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(103.0 / 255.0, 162.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(194.0 / 255.0, 182.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(241.0 / 255.0, 201.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 219.0/ 255.0)],
                                                                          nil]];
        
        // add filters
        [self addFilter:desaturation];
        [self addFilter:toneCurveFilter];
        
        // build chain
        [desaturation addTarget:toneCurveFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:desaturation]];
        [self setTerminalFilter:toneCurveFilter];
    }
    
    return self;
}

@end
