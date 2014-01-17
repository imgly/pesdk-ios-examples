//
// IMGLYEditorFilterViewController.h
// imglyKit
// 
// Created by Carsten Przyluczky on 24.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import "IMGLYAbstractEditorBaseViewController_Private.h"

@protocol IMGLYEditorImageProvider;

@interface IMGLYEditorFilterViewController : IMGLYAbstractEditorBaseViewController

@property (nonatomic, strong) IMGLYProcessingJob *currentProcessingJob;
- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end
