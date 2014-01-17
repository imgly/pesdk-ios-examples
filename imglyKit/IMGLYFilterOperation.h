//
//  IMGLYFilterOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 22.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"
#import "IMGLYOperation.h"

#import <Foundation/Foundation.h>

@interface IMGLYFilterOperation : NSObject <IMGLYOperation>

@property (nonatomic, assign) IMGLYFilterType filterType;

@end
