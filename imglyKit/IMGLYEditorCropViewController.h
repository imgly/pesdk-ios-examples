//
// IMGLYCropViewController.h
// imglyKit
// 
// Created by Carsten Przyluczky on 01.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "IMGLYAbstractEditorBaseViewController_Private.h"

typedef NS_ENUM(NSInteger, IMGLYSelectionMode) {
    IMGLYSelectionModeFree,
    IMGLYSelectionMode1to1,
    IMGLYSelectionMode4to3,
    IMGLYSelectionMode16to9
};

@interface IMGLYEditorCropViewController : IMGLYAbstractEditorBaseViewController   

@property (nonatomic, strong, setter = setInputImage:) UIImage *inputImage;
@property (nonatomic, assign, setter = setSelectionMode:) IMGLYSelectionMode selectionMode;

- (id)initWithCropRect:(CGRect) cropRect;
- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end
