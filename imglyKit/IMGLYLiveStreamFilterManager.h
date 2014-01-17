//
//  IMGLYLiveStreamFilterManager.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <Foundation/Foundation.h>
#import <NEGPUImage/GPUImage.h>

@interface IMGLYLiveStreamFilterManager : NSObject

@property (nonatomic, strong, readonly) GPUImageOutput <GPUImageInput> *currentFilter;
@property (nonatomic, assign) IMGLYFilterType filterType;

- (void)setFilterWithType:(IMGLYFilterType)filterType;

@end
