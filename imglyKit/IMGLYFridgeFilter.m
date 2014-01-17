//
//  IMGLYFridgeFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFridgeFilter.h"

@implementation IMGLYFridgeFilter

- (id)init {
    const CGFloat blueAnnotation = -20;
    self = [super init];
    if (self) {
        [self setRedControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 9.0 / 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(21.0 / 255.0, 11.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(45.0 / 255.0, 24.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1,220.0/ 255.0)]]];
        
        [self setGreenControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 12.0 / 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(21.0 / 255.0, 21.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(42.0 / 255.0, 42.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(150.0 / 255.0, 150.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(170.0 / 255.0, 173.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1, 210.0 / 255.0)]]];
        
        [self setBlueControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 28.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(43.0 / 255.0, 72.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(128.0 / 255.0, (165.0 + blueAnnotation)/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1,220.0/ 255.0)]]];
        
    }
    
    return self;
}

@end
