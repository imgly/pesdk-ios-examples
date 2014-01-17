//
//  IMGLYLenin.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYLeninFilter.h"

@implementation IMGLYLeninFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageDesaturation* desaturation = [[GPUImageDesaturation alloc] init];
        desaturation.desaturation = 0.4;
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0.0, 20 / 255)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(40.0 / 255.0, 20.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(106.0 / 255.0, 111.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(129.0 / 255.0, 153.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(190.0 / 255.0, 223.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0.0, 20 / 255)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(40.0 / 255.0, 20.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(62.0 / 255.0, 41.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(106.0 / 255.0, 108.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(132.0 / 255.0, 159.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(203.0 / 255.0, 237.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 40 / 255)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(40.0 / 255.0, 40.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(73.0 / 255.0, 60.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(133.0 / 255.0, 160.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(191.0 / 255.0, 207.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(203.0 / 255.0, 237.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(237.0 / 255.0, 239.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1,1)],
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
