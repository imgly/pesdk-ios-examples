//
//  IMGLYTiltShiftOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 05.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IMGLYTiltShiftMode) {
    IMGLYTiltShiftModeCircle,
    IMGLYTiltShiftModeBox
};

@interface IMGLYTiltShiftOperation : NSObject <IMGLYOperation>

/**
 The blurred version of the inputImage decupling that, brings many advantages. First, one can select the blur method, 
 like gaussian or possion disk. Second, the blurred image can be stored, so caching for GUIs is possible in case this 
 is nil, the operation will create a blurred image itself.
 */
@property (nonatomic, strong) UIImage *blurredImage;

@property (nonatomic, assign) CGPoint controlPoint1;
@property (nonatomic, assign) CGPoint controlPoint2;

/**
 The scale vector is out to scale the uv coordinates. That comes into play when dealing with non square image sizes.
 */
@property (nonatomic, assign) CGPoint scaleVector;

@property (nonatomic, assign) IMGLYTiltShiftMode tiltShiftMode;

@end
