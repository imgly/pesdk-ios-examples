//
//  IMGLYSemiRedFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYSemiRedFilter.h"

@implementation IMGLYSemiRedFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [toneCurveFilter setRedControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 129.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(75.0 / 255.0, 153.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(181.0 / 255.0, 227.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
        ]];
        [toneCurveFilter setGreenControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 8.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(111.0 / 255.0, 85.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(212.0 / 255.0, 158.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1,226.0 / 255.0)],
        ]];
        [toneCurveFilter setBlueControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 5.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(75.0 / 255.0, 22.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(193.0 / 255.0, 90.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 229.0 / 255.0)],
         ]];

        GPUImageColorAddGlow *colorAddGlow = [[GPUImageColorAddGlow alloc] init];

        [self addFilter:toneCurveFilter];
        [self addFilter:colorAddGlow];
        
        [toneCurveFilter addTarget:colorAddGlow];
        
        [self setInitialFilters:@[ toneCurveFilter ]];
        [self setTerminalFilter:colorAddGlow];
    }

    return self;
}

@end
