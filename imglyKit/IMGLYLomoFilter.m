//
//  IMGLYLomoFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYLomoFilter.h"

@implementation IMGLYLomoFilter

- (id)init {
    self = [super init];
    if (self) {
        [self setRGBControlPoints:[NSArray arrayWithObjects:
                                   [NSValue valueWithCGPoint:CGPointMake(0.0, 0)],
                                   [NSValue valueWithCGPoint:CGPointMake(87.0 / 255.0, 30.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(131.0 / 255.0, 146.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(183.0 / 255.0, 195.0/ 255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1, 163.0 / 208.0)],
                                   nil]];
    }
    
    return self;
}

@end
