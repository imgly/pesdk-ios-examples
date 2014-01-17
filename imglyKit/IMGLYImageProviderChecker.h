//
// IMGLYImageProviderChecker.h
// imglyKit
// 
// Created by Carsten Przyluczky on 28.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol IMGLYCameraImageProvider;
@protocol IMGLYEditorImageProvider;

@interface IMGLYImageProviderChecker : NSObject

+ (instancetype)sharedInstance;

- (void)checkCameraImageProvider:(id <IMGLYCameraImageProvider>)imageProvider;
- (void)checkEditorImageProvider:(id <IMGLYEditorImageProvider>)imageProvider;

@end
