//
//  IMGLYEarlyBirdFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEarlyBirdFilter.h"

@implementation IMGLYEarlyBirdFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0 ,  40.0 / 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1 , 230.0 / 255.0)],
                                                                         nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0 ,  10.0 / 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1 , 225.0 / 255.0)],
                                                                           nil]];
        [(GPUImageToneCurveFilter *)toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0,  20.0 / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 181.0 / 255.0)],
                                                                          nil]];
        GPUImageColorAddGlow* colorAddGlow = [[GPUImageColorAddGlow alloc] init];
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:colorAddGlow];
        
        // build chain
        [toneCurveFilter addTarget:colorAddGlow];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:toneCurveFilter]];
        [self setTerminalFilter:colorAddGlow];
        
    }
    
    return self;
}

@end
