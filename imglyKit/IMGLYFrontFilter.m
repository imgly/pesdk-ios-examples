//
//  IMGLYFrontFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 17.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFrontFilter.h"

@implementation IMGLYFrontFilter

- (id)init {
    self = [super init];
    if (self) {
        [self setRedControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 65.0 / 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(28.0 / 255.0, 67.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(67.0 / 255.0, 113.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(125.0 / 255.0, 183.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(187.0 / 255.0, 217.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1,229.0 / 255.0)]]];
        
        [self setGreenControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 52.0 / 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(42.0 / 255.0, 59.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(104.0 / 255.0, 134.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(169.0 / 255.0, 209.0/ 255.0)],
                                     [NSValue valueWithCGPoint:CGPointMake(1, 240.0 / 255.0)]]];
        
        [self setBlueControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 52.0 / 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(65.0 / 255.0, 68.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(93.0 / 255.0, 104.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(150.0 / 255.0, 153.0/ 255.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1,198.0/ 255.0)]]];
        
    }
    
    return self;
}

@end
