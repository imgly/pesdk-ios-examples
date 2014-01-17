//
//  IMGLYBrightnessFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYBrightnessFilter.h"

@implementation IMGLYBrightnessFilter

- (instancetype)init
{
    self = (IMGLYBrightnessFilter*)[[GPUImageBrightnessFilter alloc] init];
    return self;
}

@end
