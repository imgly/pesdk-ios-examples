//
//  IMGLYMellowFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYMellowFilter.h"

@implementation IMGLYMellowFilter

- (id)init {
    self = [super init];
    if (self) {
        [self setRedControlPoints:[NSArray arrayWithObjects:
                                   [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(41.0 / 255.0, 84.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(87.0 / 255.0, 134.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1,1)],
                                   nil]];
        [self setGreenControlPoints:[NSArray arrayWithObjects:
                                     [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1, 216.0 / 255.0)],
                                     nil]];
        [self setBlueControlPoints:[NSArray arrayWithObjects:
                                    [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1, 131.0 / 255.0)],
                                    nil]];
        
    }
    
    return self;
}

@end
