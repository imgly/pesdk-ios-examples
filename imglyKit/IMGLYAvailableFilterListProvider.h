//
// IMGLYAvailableFilterListProvider.h
// imglyKit
// 
// Created by Carsten Przyluczky on 25.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol IMGLYAvailableFilterListProvider <NSObject>

- (NSArray *)provideAvailableFilterList;

@end
