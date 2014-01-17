//
//  IMGLY669Filter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY669Filter.h"

@implementation IMGLY669Filter

- (instancetype)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];

        NSArray *redControlPoints = @[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
            [NSValue valueWithCGPoint:CGPointMake(56.0 / 255.0, 18.0/ 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(196.0 / 255.0, 209.0/ 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1,1)]
        ];
        [toneCurveFilter setRedControlPoints:redControlPoints];

        NSArray *greenControlPoints = @[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 38.0 / 255.0 )],
            [NSValue valueWithCGPoint:CGPointMake(71.0 / 255.0, 84.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
        ];
        [toneCurveFilter setGreenControlPoints:greenControlPoints];

        NSArray *blueControlPoints = @[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
            [NSValue valueWithCGPoint:CGPointMake(131.0 / 255.0, 133.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(204.0 / 255.0, 211.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
        ];
        [toneCurveFilter setBlueControlPoints:blueControlPoints];
        
        GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:1.5];
        
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        [saturationFilter setSaturation:0.8];
        
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastFilter];
        [self addFilter:saturationFilter];
        
        // build chain
        [toneCurveFilter addTarget:contrastFilter];
        [contrastFilter addTarget:saturationFilter];
        
        // register chain
        [self setInitialFilters:@[toneCurveFilter]];
        [self setTerminalFilter:saturationFilter];
    }
    
    return self;
}

@end
