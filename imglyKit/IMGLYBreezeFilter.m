//
//  IMGLYBreezeFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYBreezeFilter.h"

@implementation IMGLYBreezeFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageDesaturation* desaturation = [[GPUImageDesaturation alloc] init];
        desaturation.desaturation = 0.5;
        
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [toneCurveFilter setRedControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                              [NSValue valueWithCGPoint:CGPointMake(170.0 / 255.0, 170.0/ 255.0)],
                                              [NSValue valueWithCGPoint:CGPointMake(212.0 / 255.0, 219.0/ 255.0)],
                                              [NSValue valueWithCGPoint:CGPointMake(234.0 / 255.0, 242.0/ 255.0)],
                                              [NSValue valueWithCGPoint:CGPointMake(1,1)]]];
        [toneCurveFilter setGreenControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                                [NSValue valueWithCGPoint:CGPointMake(170.0 / 255.0, 168.0 / 255.0)],
                                                [NSValue valueWithCGPoint:CGPointMake(234.0 / 255.0, 231.0 / 255.0)],
                                                [NSValue valueWithCGPoint:CGPointMake(1, 1)]]];
        [toneCurveFilter setBlueControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                               [NSValue valueWithCGPoint:CGPointMake(170.0 / 255.0, 170.0 / 255.0)],
                                               [NSValue valueWithCGPoint:CGPointMake(212.0 / 255.0, 208.0 / 255.0)],
                                               [NSValue valueWithCGPoint:CGPointMake(1, 1)]]];
        
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
