//
//  IMGLY8BitFIlter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 23.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLY8BitFIlter.h"

@implementation IMGLY8BitFIlter

- (instancetype)init
{
    self = (IMGLY8BitFIlter*)[[GPUImagePosterizeFilter alloc] init];
    if (self) {
        [self setColorLevels:3];
    }
    return self;
}

@end
