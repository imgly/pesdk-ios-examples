//
//  IMGLYChestNutFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYChestNutFilter.h"

@implementation IMGLYChestNutFilter

- (id)init {
    self = [super init];
    if (self) {
         
        [self setRedControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(44.0 / 255.0, 44.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(124.0 / 255.0, 143.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(221.0 / 255.0, 204.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1,1)]]];
        
        [self setGreenControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                     [NSValue valueWithCGPoint:CGPointMake(130.0 / 255.0, 127.0 / 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(213.0 / 255.0, 199.0 / 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1, 1)]]];

        [self setBlueControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                    [NSValue valueWithCGPoint:CGPointMake(51.0 / 255.0, 52.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(219.0 / 255.0, 204.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1, 1)]]];
    }
    
    return self;
}

@end
