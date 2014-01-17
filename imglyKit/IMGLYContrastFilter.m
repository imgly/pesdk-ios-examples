//
//  IMGLYContrastFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYContrastFilter.h"

@implementation IMGLYContrastFilter

- (instancetype)init
{
    self = (IMGLYContrastFilter*)[[GPUImageContrastFilter alloc] init];
    return self;
}

@end
