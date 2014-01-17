//
//  IMGLYCropOperation.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

@interface IMGLYCropOperation : NSObject <IMGLYOperation>

@property (nonatomic, assign) CGRect rect;

- (instancetype)initWithRect:(CGRect)rect;

@end
