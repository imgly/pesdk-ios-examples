//
//  IMGLYTejasFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYTejasFilter.h"

@implementation IMGLYTejasFilter

- (id)init {
    self = [super init];
    if (self) {
        [self setRedControlPoints:[NSArray arrayWithObjects:
                                   [NSValue valueWithCGPoint:CGPointMake(0, 72.0 / 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(89.0 / 255.0, 99.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(176.0 / 255.0, 212.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1, 237.0 / 255.0)],
                                   nil]];
        [self setGreenControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0.0, 49.0 / 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1 , 192.0/ 255.0)],
                                     nil]];
        [self setBlueControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0, 72.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1, 151.0 / 255.0)],
                                    nil]];
    }
    
    return self;
}

@end
