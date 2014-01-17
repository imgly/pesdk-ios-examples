//
//  IMGLYPolaFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYPolaFilter.h"

@implementation IMGLYPolaFilter

- (id)init {
    self = [super init];
    if (self) {
        GPUImageToneCurveFilter* toneCurveFilter = [[GPUImageToneCurveFilter alloc] init];
        
        NSArray *redControlPoints = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(94.0 / 255.0, 74.0/ 255.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(181.0 / 255.0, 205.0/ 255.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(1,1)]
                                      ];
        [toneCurveFilter setRedControlPoints:redControlPoints];
        
        NSArray *greenControlPoints = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                        [NSValue valueWithCGPoint:CGPointMake(34.0 / 255.0, 34.0 / 255.0)],
                                        [NSValue valueWithCGPoint:CGPointMake(99.0 / 255.0, 76.0 / 255.0)],
                                        [NSValue valueWithCGPoint:CGPointMake(176.0 / 255.0, 190.0 / 255.0)],
                                      [NSValue valueWithCGPoint:CGPointMake(1,1)]
                                      ];
        [toneCurveFilter setGreenControlPoints:greenControlPoints];

        NSArray *blueControlPoints = @[[NSValue valueWithCGPoint:CGPointMake(0 , 0)],
                                       [NSValue valueWithCGPoint:CGPointMake(102.0 / 255.0, 73.0 / 255.0)],
                                       [NSValue valueWithCGPoint:CGPointMake(227.0 / 255.0, 213.0 / 255.0)],
                                       [NSValue valueWithCGPoint:CGPointMake(1, 1)]
                                       ];
        [toneCurveFilter setGreenControlPoints:blueControlPoints];
        
        GPUImageContrastFilter* contrastFilter = [[GPUImageContrastFilter alloc] init];
        [contrastFilter setContrast:(1.5)];
        
        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        [saturationFilter setSaturation:0.8];
        
        // add filters
        [self addFilter:toneCurveFilter];
        [self addFilter:contrastFilter];
        [self addFilter:saturationFilter];
        
        // build chain
        [toneCurveFilter addTarget:contrastFilter];
        [contrastFilter addTarget:saturationFilter];
        
        // register chain
        [self setInitialFilters:[NSArray arrayWithObject:toneCurveFilter]];
        [self setTerminalFilter:saturationFilter];
    }
    
    return self;
}

@end
