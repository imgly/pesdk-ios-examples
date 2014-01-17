//
//  IMGLYCameraImageProvider.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMGLYCameraImageProvider <NSObject>

- (UIImage *)cameraButtonImage;
- (UIImage *)filterSelectorArrowUpImage;
- (UIImage *)filterSelectorArrowDownImage;
- (UIImage *)selectFromCameraRollImage;
- (UIImage *)toggleFlashImage;
- (UIImage *)swapCameraImage;
- (UIImage *)bottomBarForCamera3_5InchImage;
- (UIImage *)bottomBarForCamera4InchImage;
- (UIImage *)shutterBladeImage;
- (UIImage *)gradientImage;
- (UIImage *)filterPreviewImage;
- (UIImage *)filterActiveIcon;

@end
