//
// IMGLYEditorCropMenu.h
// imglyKit
// 
// Created by Carsten Przyluczky on 01.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "IMGLYEditorCropViewController.h"

@protocol IMGLYEditorCropMenuDelegate;

@interface IMGLYEditorCropMenu : UIView

@property (nonatomic, weak) id<IMGLYEditorCropMenuDelegate> menuDelegate;

- (void)setSelectionMode:(IMGLYSelectionMode) cropMode;
- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end

@protocol IMGLYEditorCropMenuDelegate <NSObject>

- (void)freeFormButtonTouchedUpInside;
- (void)squareFormButtonTouchedUpInside;
- (void)ratio4to3FormButtonTouchedUpInside;
- (void)ratio16to9FormButtonTouchedUpInside;

@end
