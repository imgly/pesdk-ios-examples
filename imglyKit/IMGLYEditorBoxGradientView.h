//
//  IMGLYEditorBoxGradientView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 06.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGLYEditorGradientViewDelegate.h"

@interface IMGLYEditorBoxGradientView : UIView

@property (nonatomic, assign) CGPoint controllPoint1;
@property (nonatomic, assign) CGPoint controllPoint2;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, weak) id<IMGLYEditorGradientViewDelegate> gradientViewDelegate;

- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;
- (void)calculateCenterPointFromOtherControlPoints;

@end
