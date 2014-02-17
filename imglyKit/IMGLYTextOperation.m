//
//  IMGLYTextOperation.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 05.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYTextOperation.h"
#import "IMGLYPhotoProcessor_Private.h"

@implementation IMGLYTextOperation

- (UIImage *)processImage:(UIImage *)image {
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0.0, 0.0, image.size.width,image.size.height)];
    CGRect rect = CGRectIntegral(CGRectMake(self.position.x * image.size.width, self.position.y * image.size.height, image.size.width * 2.0, image.size.height * 2.0));
    [self.color set];
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontHeightScaleFactor * image.size.height ];
    [self.text drawInRect:rect withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (id)copy {
    IMGLYTextOperation *copy = [[IMGLYTextOperation alloc] init];
    copy.text = _text;
    copy.color = _color;
    copy.fontName = _fontName;
    return copy;
}


@end
