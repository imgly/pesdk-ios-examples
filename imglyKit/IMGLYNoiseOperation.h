//
//  IMGLYNoiseOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 04.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

#import <UIKit/UIKit.h>

@interface IMGLYNoiseOperation : NSObject  <IMGLYOperation>

/**
 This value controlls the strengh or intensity of the noise. 0 means no change, and 1 strong noise.
 */
@property (nonatomic, assign) CGFloat intensity;

/**
 A 512x512 large noise image decupling that, brings many adventages. For example the noise Image can be stored in a 
 view controller that allows faster processing.
 */
@property (nonatomic, strong) UIImage *noiseImage;

@end
