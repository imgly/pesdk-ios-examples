//
//  UIImage+IMGLYKitAdditions.m
//  imglyKit
//
//  Created by Manuel Binna on 13.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "UIImage+IMGLYKitAdditions.h"

#import "NSBundle+IMGLYAdditions.h"

@implementation UIImage (IMGLYKitAdditions)

+ (UIImage *)imgly_imageNamed:(NSString *)name {
    NSString *imageName = [NSString stringWithFormat:@"%@/%@", IMGLYBundleName, name];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)imgly_resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            drawTransposed = NO;
            break;
    }

    CGAffineTransform transform = [self imgly_transformForOrientation:newSize];

    return [self imgly_resizedImage:newSize
                          transform:transform
                     drawTransposed:drawTransposed
               interpolationQuality:quality];
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)imgly_resizedImage:(CGSize)newSize
                      transform:(CGAffineTransform)transform
                 drawTransposed:(BOOL)transpose
           interpolationQuality:(CGInterpolationQuality)quality {
    
    CGRect newRect = CGRectIntegral(CGRectMake(0.0, 0.0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0.0, 0.0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                rgbColorSpace,
                                                CGImageGetBitmapInfo(imageRef));
    CGColorSpaceRelease(rgbColorSpace);

    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    CGContextRelease(bitmap);

    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)imgly_transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationDown:
        case UIImageOrientationUp:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    return transform;
}

- (UIImage *)imgly_rotateImageToMatchOrientation {
    CGImageRef imageRef = self.CGImage;
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);

    CGRect bounds = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);

    CGFloat scaleRatio = bounds.size.width / imageWidth;
    CGFloat boundHeight;
    UIImageOrientation imageoOrientation = self.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(imageoOrientation) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;

        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;

        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0f, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
            break;

        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI_2);
            break;

        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0f, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI_2);
            break;

        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
    }

    UIGraphicsBeginImageContext(bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (imageoOrientation == UIImageOrientationRight || imageoOrientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -imageHeight, 0.0f);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0.0f, -imageHeight);
    }

    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0.0f, 0.0f, imageWidth, imageHeight), imageRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imageCopy;
}

@end
