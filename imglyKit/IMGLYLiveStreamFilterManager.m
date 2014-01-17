//
//  IMGLYLiveStreamFilterManager.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYLiveStreamFilterManager.h"

#import "IMGLYFilter.h"

@interface IMGLYLiveStreamFilterManager ()

@property (nonatomic, strong, readwrite) GPUImageOutput <GPUImageInput> *currentFilter;

@end

#pragma mark -

@implementation IMGLYLiveStreamFilterManager

- (id)init {
    self = [super init];
    if (self) {
        _currentFilter = [IMGLYFilter filterWithType:IMGLYFilterTypeNone];
        _filterType = IMGLYFilterTypeNone;
    }
    
    return self;
}

- (void)setFilterWithType:(IMGLYFilterType)filterType {
    if (_filterType != filterType) {
        _filterType = filterType;
        self.currentFilter = [IMGLYFilter filterWithType:filterType];
    }
}

@end
