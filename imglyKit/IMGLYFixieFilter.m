//
//  IMGLYFixieFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFixieFilter.h"

@implementation IMGLYFixieFilter

- (id)init {
    self = [super init];
    if (self) {
        [self setRedControlPoints:[NSArray arrayWithObjects:
                                   [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0 )],
                                   [NSValue valueWithCGPoint:CGPointMake(44.0 / 255.0, 28.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(63.0 / 255.0, 48.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(128.0 / 255.0, 132.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(235.0 / 255.0, 248.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                   nil]];
        [self setGreenControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                     [NSValue valueWithCGPoint:CGPointMake(20.0 / 255.0, 10.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(60.0 / 255.0, 45.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(190.0 / 255.0, 209.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(211.0 / 255.0, 231.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                     nil]];
        [self setBlueControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 31.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(41.0 / 255.0, 62.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(150.0 / 255.0, 142.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(234.0 / 255.0, 212.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1, 224.0/ 255.0)],
                                    nil]];
        
    }
    
    return self;
}

@end
