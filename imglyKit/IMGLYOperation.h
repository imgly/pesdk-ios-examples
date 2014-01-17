//
//  IMGLYOperation.h
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMGLYOperation <NSObject>

- (UIImage *)processImage:(UIImage *)image;
- (id) copy;

@end
