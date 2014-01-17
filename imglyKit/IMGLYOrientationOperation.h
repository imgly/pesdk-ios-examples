//
//  IMGLYRotateOperation.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"
#import "IMGLYOrientationFilter.h"

#import <Foundation/Foundation.h>

@interface IMGLYOrientationOperation : NSObject  <IMGLYOperation>

@property (nonatomic, assign) IMGLYRotationAngle rotationAngle;

- (void)rotateRight;
- (void)rotateLeft;

- (void)flipHorizontal;
- (void)flipVertical;

@end
