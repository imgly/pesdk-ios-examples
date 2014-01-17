//
//  IMGLY9EK2Filter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY9EK2Filter.h"

@implementation IMGLY9EK2Filter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [(GPUImageToneCurveFilter *)toneCurveFilter setRGBControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(54.0 / 255.0, 33.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(77.0 / 255.0, 82.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(94.0 / 255.0, 103.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(122.0 / 255.0, 126.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(177.0 / 255.0, 193.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(229.0 / 255.0, 232.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1,1)]]];
        
        GPUImageSoftColorOverlay *overlay = [[GPUImageSoftColorOverlay alloc] init];
        [overlay setOverlayColorRed:40 green:40 blue:40];
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:overlay];
        
        // build chain
        [toneCurveFilter addTarget:overlay];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:toneCurveFilter]];
        [self setTerminalFilter:overlay];
    }
    
    return self;
}


@end
