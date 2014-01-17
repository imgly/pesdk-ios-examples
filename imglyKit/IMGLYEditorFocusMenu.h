//
//  IMGLYEditorFocusMenu.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 08.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGLYEditorFocusViewController.h"
#import "IMGLYTiltShiftOperation.h"

@protocol IMGLYEditorFocusMenuDelegate;
@protocol IMGLYEditorImageProvider;

@interface IMGLYEditorFocusMenu : UIView

@property (nonatomic, weak) id<IMGLYEditorFocusMenuDelegate> menuDelegate;

- (void)setTiltShiftMode:(IMGLYTiltShiftMode) tiltShiftMode;
- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end

@protocol IMGLYEditorFocusMenuDelegate <NSObject>

- (void)circleModeTouchedUpInside;
- (void)boxModeTouchedUpInside;

@end
