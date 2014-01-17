//
//  IMGLYContrastOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

#import <Foundation/Foundation.h>

@interface IMGLYContrastOperation :  NSObject  <IMGLYOperation>

/**
 This value controlls the contrast factor. It ranges from 0 to 2. 1 means no change.
 */
@property (nonatomic, assign) CGFloat contrast;

@end
