//
//  IMGLY9EKDynamicFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY9EKDynamicFilter.h"

@implementation IMGLY9EKDynamicFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRGBControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(17.0 / 255.0, 27.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(46.0 / 255.0, 69.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(90.0 / 255.0, 112.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(156.0 / 255.0, 200.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(203.0 / 255.0, 243.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)]]];
        
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        [saturationFilter setSaturation:0.7];
        
        [self addFilter:saturationFilter];
        [self addFilter:toneCurveFilter];
        
        // build chain
        [saturationFilter addTarget:toneCurveFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:saturationFilter]];
        [self setTerminalFilter:toneCurveFilter];
    }
    
    return self;
}


@end
