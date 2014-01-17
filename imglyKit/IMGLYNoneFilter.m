//
//  IMGLYNoneFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYNoneFilter.h"

@implementation IMGLYNoneFilter

- (instancetype)init {
    self = (IMGLYNoneFilter*)[[GPUImageCropFilter alloc] init];
    return self;
}
@end
