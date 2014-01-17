//
//  IMGLYMainMenuEntryMetaData.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 01.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYMainMenuEntryMetaData.h"

@implementation IMGLYMainMenuEntryMetaData

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image viewControllerClass:(Class)viewControllerClass {
    self = [super init];
    if (self) {
        _image = image;
        _text = text;
        _viewControllerClass = viewControllerClass;
    }
    return self;
}

@end
