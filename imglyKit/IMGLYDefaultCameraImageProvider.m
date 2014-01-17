//
//  IMGLYDefaultCameraImageProvider.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYDefaultCameraImageProvider.h"

#import "UIImage+IMGLYKitAdditions.h"
#import "IMGLYDeviceDetector.h"


@implementation IMGLYDefaultCameraImageProvider

- (UIImage *)shutterBladeImage {
    return [UIImage imgly_imageNamed:@"blade"];
}

- (UIImage *)cameraButtonImage {
    if ([IMGLYDeviceDetector isRunningOn4Inch])
        return [UIImage imgly_imageNamed:@"cambutton"];
    else
        return [UIImage imgly_imageNamed:@"cambutton_35"];
}

- (UIImage *)filterSelectorArrowUpImage {
    return[UIImage imgly_imageNamed:@"filterArrowUp"];
}

- (UIImage *)filterSelectorArrowDownImage {
    return [UIImage imgly_imageNamed:@"filterArrowDown"];
}

- (UIImage *)selectFromCameraRollImage {
    return [UIImage imgly_imageNamed:@"cameraRoll"];
}

- (UIImage *)toggleFlashImage {
    return [UIImage imgly_imageNamed:@"cam_flash"];
}

- (UIImage *)swapCameraImage {
    return [UIImage imgly_imageNamed:@"cam_change"];
}

- (UIImage *)bottomBarForCamera3_5InchImage {
    return [UIImage imgly_imageNamed:@"cambar_4"];
}

- (UIImage *)bottomBarForCamera4InchImage {
    return [UIImage imgly_imageNamed:@"cambar_5"];
}

- (UIImage *)gradientImage {
    return [UIImage imgly_imageNamed:@"gradient"];
}

- (UIImage *)filterPreviewImage {
    return [UIImage imgly_imageNamed:@"nonePreview"];
}

- (UIImage *)filterActiveIcon {
    return [UIImage imgly_imageNamed:@"icon_filter_active"];
}

@end
