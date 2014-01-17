//
//  IMGLY9EK1Filter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY9EK1Filter.h"

@implementation IMGLY9EK1Filter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRGBControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(53.0 / 255.0, 32.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(91.0 / 255.0, 80.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(176.0 / 255.0, 205.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)]]];
        
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        [saturationFilter setSaturation:0.9];
        
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:saturationFilter];
        
        // build chain
        [toneCurveFilter addTarget:saturationFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:toneCurveFilter]];
        [self setTerminalFilter:saturationFilter];
    }
    
    return self;
}

@end
