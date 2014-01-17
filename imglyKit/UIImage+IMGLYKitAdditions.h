//
//  UIImage+IMGLYKitAdditions.h
//  imglyKit
//
//  Created by Manuel Binna on 13.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Adds framework-related methods to `UIImage`.
 */
@interface UIImage (IMGLYKitAdditions)

#pragma mark Loading an Image

/**
 * Returns the image object associated with the specified filename. Loads the image from the framework bundle.
 *
 * @param name The name of the file. If this is the first time the image is being loaded, the method looks for an image 
 *             with the specified name in the framework's bundle.
 *
 * @return The image object for the specified file, or `nil` if the method could not find the specified image.
 */
+ (UIImage *)imgly_imageNamed:(NSString *)name;

#pragma mark Editing the Image

/**
 * Returns a copy of this image that is cropped to the given bounds.
 *
 * @param bounds The bounds within the image to crop. The bounds will be adjusted using CGRectIntegral.
 * @return The cropped image.
 *
 * @discussion This method ignores the image's imageOrientation setting.
 */
- (UIImage *)imgly_croppedImage:(CGRect)bounds;

/**
 * Returns a rescaled copy of the image, taking into account its orientation
 *
 * @param newSize The size of the rescaled image.
 * @param quality The quality of the rescaled image.
 * @return The rescaled image.
 *
 * @discussion The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter.
 */ 
- (UIImage *)imgly_resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

/**
 * Returns a resized image according to the given content mode, taking into account the image's orientation.
 *
 * @param contentMode The content mode of the resized image.
 * @param bounds The bounds of the resized image.
 * @param quality The quality of the resized image.
 * @return The resized image.
 */
- (UIImage *)imgly_resizedImageWithContentMode:(UIViewContentMode)contentMode
                                        bounds:(CGSize)bounds
                          interpolationQuality:(CGInterpolationQuality)quality;

/**
 * @return The normalized image.
 */
- (UIImage *)imgly_normalizedImage;


- (UIImage *)imgly_rotateImageToMatchOrientation;

@end
