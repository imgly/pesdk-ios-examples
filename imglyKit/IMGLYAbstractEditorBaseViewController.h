//
// IMGLYAbstractEditorBaseViewController.h
// imglyKit
// 
// Created by Carsten Przyluczky on 24.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//
// THIS CLASS SERVES AS -ABSTRACT- BASE CLASS, IT MUST NOT TO BE INSTANCIATED !!

#import <UIKit/UIKit.h>

@class IMGLYProcessingJob;
@protocol IMGLYEditorImageProvider;

typedef NS_ENUM(NSInteger, IMGLYEditorViewControllerResult) {
    IMGLYEditorViewControllerResultCancelled,
    IMGLYEditorViewControllerResultDone
};

typedef void (^IMGLYEditorViewControllerCompletionHandler)(IMGLYEditorViewControllerResult result,
                                                           UIImage *outputImage,
                                                           IMGLYProcessingJob *job);

@interface IMGLYAbstractEditorBaseViewController : UIViewController

@property (nonatomic, strong) UIImage *inputImage;
@property (nonatomic, copy) IMGLYEditorViewControllerCompletionHandler completionHandler;

- (instancetype)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end
