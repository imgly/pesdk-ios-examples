//
//  IMGLYEditorCircleGradientView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 07.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGLYEditorGradientViewDelegate.h"

@protocol IMGLYEditorImageProvider;

@interface IMGLYEditorCircleGradientView : UIView

@property (nonatomic, assign) CGPoint controllPoint1;
@property (nonatomic, assign) CGPoint controllPoint2;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, weak) id<IMGLYEditorGradientViewDelegate> gradientViewDelegate;

- (void)calculateCenterPointFromOtherControlPoints;
- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end
