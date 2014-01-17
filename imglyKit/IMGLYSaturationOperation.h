//
//  IMGLYSaturationOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

@interface IMGLYSaturationOperation : NSObject  <IMGLYOperation>

/**
 This value controlls the saturation factor. It ranges from 0 to 2. 1 means no change.
 */
@property (nonatomic, assign) CGFloat saturation;

@end
