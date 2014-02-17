//
//  IMGLYTextOperation.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 05.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYOperation.h"

#import <Foundation/Foundation.h>

@interface IMGLYTextOperation : NSObject <IMGLYOperation>

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, assign) CGFloat fontHeightScaleFactor;

@property (nonatomic, assign) CGPoint position;

@end
