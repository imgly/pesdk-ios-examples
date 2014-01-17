//
//  IMGLYDefaultImageProvider.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYDefaultEditorImageProvider.h"
#import "UIImage+IMGLYKitAdditions.h"

@implementation IMGLYDefaultEditorImageProvider

- (UIImage *)bottomBarForEditorImage {
    return [UIImage imgly_imageNamed:@"new_bottombar"];
}

- (UIImage *)cropDragPointImage {
    return  [UIImage imgly_imageNamed:@"crop_nubsi"];
}

- (UIImage *)filterIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_filters.png"];
}

- (UIImage *)orientationIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_orientation.png"];
}

- (UIImage *)focusIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_focus.png"];
}

- (UIImage *)cropIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_crop.png"];
}

- (UIImage *)brightnessIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_brightness.png"];
}

- (UIImage *)contrastIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_contrast.png"];
}

- (UIImage *)saturationIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_saturation.png"];
}

- (UIImage *)noiseIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_noise.png"];
}

- (UIImage *)textIcon {
    return  [UIImage imgly_imageNamed:@"icon_option_text.png"];
}

- (UIImage *)rotateLeftIcon {
    return  [UIImage imgly_imageNamed:@"icon_orientation_rotate-l"];
}

- (UIImage *)rotateRightIcon {
    return  [UIImage imgly_imageNamed:@"icon_orientation_rotate-r"];
}

- (UIImage *)flipHorizontalIcon {
    return  [UIImage imgly_imageNamed:@"icon_orientation_flip-h"];
}

- (UIImage *)flipVerticalIcon {
    return  [UIImage imgly_imageNamed:@"icon_orientation_flip-v"];
}

- (UIImage *)radialFocusIcon {
    return  [UIImage imgly_imageNamed:@"icon_focus_radial"];
}

- (UIImage *)linearFocusIcon {
    return  [UIImage imgly_imageNamed:@"icon_focus_linear"];
}

- (UIImage *)focusAnchorImage {
    return  [UIImage imgly_imageNamed:@"crosshair"];
}

- (UIImage *)customRatioIcon {
    return  [UIImage imgly_imageNamed:@"icon_crop_custom"];
}

- (UIImage *)oneToOneRatioIcon {
    return  [UIImage imgly_imageNamed:@"icon_crop_square"];
}

- (UIImage *)fourToThreeRatioIcon {
    return  [UIImage imgly_imageNamed:@"icon_crop_4-3"];
}

- (UIImage *)sixteenToNineRatioIcon {
    return  [UIImage imgly_imageNamed:@"icon_crop_16-9"];
}

- (UIImage *)gradientImage {
    return [UIImage imgly_imageNamed:@"gradient"];
}

- (UIImage *)resetButtonIcon {
    return [UIImage imgly_imageNamed:@"icon_undo"];
}

- (UIImage *)magicButtonIcon{
    return [UIImage imgly_imageNamed:@"icon_magic"];
}

- (UIImage *)magicActiveButtonIcon {
    return [UIImage imgly_imageNamed:@"icon_magic_active"];
}

- (UIImage *)filterActiveIcon {
    return [UIImage imgly_imageNamed:@"icon_filter_active"];
}

@end
