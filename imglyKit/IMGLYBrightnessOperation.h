//
//  IMGLYBrightnessOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

#import <Foundation/Foundation.h>

@interface IMGLYBrightnessOperation : NSObject  <IMGLYOperation>

/**
 This value controlls the brighness addition / substraction. It ranges from -1 (complete black) to 1 (complete white).
 0 means no change.
 */
@property (nonatomic, assign) CGFloat brightness;

@end
