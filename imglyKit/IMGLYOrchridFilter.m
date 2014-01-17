//
//  IMGLYOrchridFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOrchridFilter.h"

@implementation IMGLYOrchridFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [toneCurveFilter setRedControlPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(115.0 / 255.0, 130.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(195.0 / 255.0, 215.0/ 255.0)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                         nil]];
        [toneCurveFilter setGreenControlPoints:[NSArray arrayWithObjects:
                                                                           [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(148.0 / 255.0, 153.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(172.0 / 255.0, 215.0/ 255.0)],
                                                                           [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                           nil]];
        [toneCurveFilter setBlueControlPoints:[NSArray arrayWithObjects:
                                                                          [NSValue valueWithCGPoint:CGPointMake(0, 46.0  / 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(58.0 / 255.0, 75.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(178.0 / 255.0, 205.0/ 255.0)],
                                                                          [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                                                          nil]];
        
        GPUImageToneCurveFilter *contrastCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        [contrastCurveFilter setRGBControlPoints:@[
            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
            [NSValue valueWithCGPoint:CGPointMake(117.0 / 255.0, 151.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(189.0 / 255.0, 217.0 / 255.0)],
            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
         ]];
        
        GPUImageDesaturation* desaturation = [[GPUImageDesaturation alloc] init];
        desaturation.desaturation = 0.65;
        
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastCurveFilter];
        [self addFilter:desaturation];
        
        [toneCurveFilter addTarget:contrastCurveFilter];
        [contrastCurveFilter addTarget:desaturation];

        [self setInitialFilters:@[ toneCurveFilter ]];
        [self setTerminalFilter:desaturation];
    }
    
    return self;
}
@end
