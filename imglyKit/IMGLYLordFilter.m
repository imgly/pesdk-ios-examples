//
//  IMGLYLoardFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYLordFilter.h"

@implementation IMGLYLordFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter *toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [toneCurveFilter setBlueControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 76.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(39.0 / 255.0, 82.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(218.0 / 255.0, 138.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(255.0 / 255.0, 171.0 / 255.0)]
        ]];
        [toneCurveFilter setRedControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 69.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(55.0 / 255.0, 110.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(202.0 / 255.0, 230.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(255.0 / 255.0, 255.0 / 255.0)]
        ]];
        [toneCurveFilter setGreenControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 44.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(89.0 / 255.0, 93.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(185.0 / 255.0, 141.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(255.0 / 255.0, 189.0 / 255.0)]
        ]];

        GPUImageToneCurveFilter *contrastCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [contrastCurveFilter setRGBControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
            [NSValue valueWithCGPoint:CGPointMake(130.0 / 255.0, 158.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(189.0 / 255.0, 246.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
        ]];
        
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastCurveFilter];

        [toneCurveFilter addTarget:contrastCurveFilter];
        
        [self setInitialFilters:@[ toneCurveFilter ]];
        [self setTerminalFilter:contrastCurveFilter];
    }

    return self;
}

@end
