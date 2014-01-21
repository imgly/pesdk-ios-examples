//
// IMGLYImageProviderChecker
// imglyKit
// 
// Created by Carsten Przyluczky on 28.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import "IMGLYImageProviderChecker.h"

#import "IMGLYCameraImageProvider.h"
#import "IMGLYEditorImageProvider.h"

#import "IMGLYDefaultCameraImageProvider.h"
#import "IMGLYDefaultEditorImageProvider.h"

@implementation IMGLYImageProviderChecker

#pragma mark - singleton
+ (instancetype)sharedInstance {
    static IMGLYImageProviderChecker *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


#pragma mark - camera image provider check
- (void)checkCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    [self checkImageExistensForCameraImageProvider:imageProvider];
    [self checkImageDimensionsForCameraImageProvider:imageProvider];
}

- (void)checkImageExistensForCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    NSAssert(imageProvider.filterPreviewImage != nil, @"filterPreviewImage may not be nil");
    NSAssert(imageProvider.toggleFlashImage != nil, @"toggleFlashImage may not be nil");
    NSAssert(imageProvider.swapCameraImage != nil, @"swapCameraImage may not be nil");
    NSAssert(imageProvider.bottomBarForCamera3_5InchImage != nil, @"bottomBarForCamera3_5InchImage may not be nil");
    NSAssert(imageProvider.bottomBarForCamera4InchImage != nil, @"bottomBarForCamera4InchImage may not be nil");
    NSAssert(imageProvider.cameraButtonImage != nil, @"cameraButtonImage may not be nil");
    NSAssert(imageProvider.filterSelectorArrowDownImage != nil, @"filterSelectorArrowDownImage may not be nil");
    NSAssert(imageProvider.filterSelectorArrowUpImage != nil, @"filterSelectorArrowUpImage may not be nil");
    NSAssert(imageProvider.gradientImage != nil, @"gradientImage may not be nil");
    NSAssert(imageProvider.selectFromCameraRollImage != nil, @"selectFromCameraRollImage may not be nil");
    NSAssert(imageProvider.shutterBladeImage != nil, @"shutterBladeImage may not be nil");
}

- (void)checkImageDimensionsForCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    // Local variable may be unused, if module is compiled with NS_BLOCK_ASSERTIONS defined.
    __unused IMGLYDefaultCameraImageProvider *defaultCameraImageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    
    NSAssert([self size:imageProvider.filterPreviewImage.size equals:defaultCameraImageProvider.filterPreviewImage.size] == YES, @"filterPreview image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.toggleFlashImage.size equals:defaultCameraImageProvider.toggleFlashImage.size] == YES, @"toggleFlashImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.swapCameraImage.size equals:defaultCameraImageProvider.swapCameraImage.size] == YES, @"filterPreview image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.cameraButtonImage.size equals:defaultCameraImageProvider.cameraButtonImage.size] == YES, @"cameraButtonImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.gradientImage.size equals:defaultCameraImageProvider.gradientImage.size] == YES, @"gradientImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.selectFromCameraRollImage.size equals:defaultCameraImageProvider.selectFromCameraRollImage.size] == YES, @"selectFromCameraRollImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.shutterBladeImage.size equals:defaultCameraImageProvider.shutterBladeImage.size] == YES, @"shutterBladeImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.filterSelectorArrowDownImage.size equals:defaultCameraImageProvider.filterSelectorArrowDownImage.size] == YES, @"filterSelectorArrowDownImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.filterSelectorArrowUpImage.size equals:defaultCameraImageProvider.filterSelectorArrowUpImage.size] == YES, @"filterSelectorArrowUpImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
    NSAssert([self size:imageProvider.bottomBarForCamera4InchImage.size equals:defaultCameraImageProvider.bottomBarForCamera4InchImage.size] == YES, @"bottomBarForCamera4InchImage image must have a size of %f x %f",defaultCameraImageProvider.filterPreviewImage.size.width, defaultCameraImageProvider.filterPreviewImage.size.height);
}

#pragma mark - editor image provider check
- (void)checkEditorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    [self checkImageExistensForEditorImageProvider:imageProvider];
    [self checkImageDimensionsForEditorImageProvider:imageProvider];
}

- (void)checkImageExistensForEditorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    NSAssert(imageProvider.resetButtonIcon != nil, @"resetButtonIcon may not be nil");
    NSAssert(imageProvider.magicButtonIcon != nil, @"magicButtonIcon may not be nil");
    NSAssert(imageProvider.magicActiveButtonIcon != nil, @"magicActiveButtonIcon may not be nil");
    NSAssert(imageProvider.textIcon != nil, @"textIcon may not be nil");
    NSAssert(imageProvider.bottomBarForEditorImage != nil, @"bottomBarForEditorImage may not be nil");
    NSAssert(imageProvider.brightnessIcon != nil, @"brightnessIcon may not be nil");
    NSAssert(imageProvider.contrastIcon != nil, @"contrastIcon may not be nil");
    NSAssert(imageProvider.cropDragPointImage != nil, @"cropDragPointImage may not be nil");
    NSAssert(imageProvider.customRatioIcon != nil, @"customRatioIcon may not be nil");
    NSAssert(imageProvider.filterIcon != nil, @"filterIcon may not be nil");
    NSAssert(imageProvider.flipHorizontalIcon != nil, @"flipHorizontalIcon may not be nil");
    NSAssert(imageProvider.flipVerticalIcon != nil, @"flipVerticalIcon may not be nil");
    NSAssert(imageProvider.focusAnchorImage != nil, @"focusAnchorImage may not be nil");
    NSAssert(imageProvider.focusIcon != nil, @"focusIcon may not be nil");
    NSAssert(imageProvider.cropIcon != nil, @"cropIcon may not be nil");
    NSAssert(imageProvider.fourToThreeRatioIcon != nil, @"fourToThreeRatioIcon may not be nil");
    NSAssert(imageProvider.gradientImage != nil, @"gradientImage may not be nil");
    NSAssert(imageProvider.linearFocusIcon != nil, @"linearFocusIcon may not be nil");
    NSAssert(imageProvider.radialFocusIcon != nil, @"radialFocusIcon may not be nil");
    NSAssert(imageProvider.noiseIcon != nil, @"noiseIcon may not be nil");
    NSAssert(imageProvider.orientationIcon != nil, @"orientationIcon may not be nil");
    NSAssert(imageProvider.oneToOneRatioIcon != nil, @"oneToOneRatioIcon may not be nil");
    NSAssert(imageProvider.saturationIcon != nil, @"saturationIcon may not be nil");
    NSAssert(imageProvider.sixteenToNineRatioIcon != nil, @"sixteenToNineRatioIcon may not be nil");
    NSAssert(imageProvider.rotateLeftIcon != nil, @"rotateLeftIcon may not be nil");
    NSAssert(imageProvider.rotateRightIcon != nil, @"rotateRightIcon may not be nil");
}

- (void)checkImageDimensionsForEditorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    // Local variable may be unused, if module is compiled with NS_BLOCK_ASSERTIONS defined.
    __unused IMGLYDefaultEditorImageProvider *defaultEditorImageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];

    NSAssert([self size:imageProvider.rotateLeftIcon.size equals:defaultEditorImageProvider.rotateLeftIcon.size] == YES, @"rotateLeftIcon image must have a size of %f x %f",defaultEditorImageProvider.rotateLeftIcon.size.width, defaultEditorImageProvider.rotateLeftIcon.size.height);
    NSAssert([self size:imageProvider.rotateRightIcon.size equals:defaultEditorImageProvider.rotateRightIcon.size] == YES, @"rotateRightIcon image must have a size of %f x %f",defaultEditorImageProvider.rotateRightIcon.size.width, defaultEditorImageProvider.rotateRightIcon.size.height);
    NSAssert([self size:imageProvider.resetButtonIcon.size equals:defaultEditorImageProvider.resetButtonIcon.size] == YES, @"resetButtonIcon image must have a size of %f x %f",defaultEditorImageProvider.resetButtonIcon.size.width, defaultEditorImageProvider.resetButtonIcon.size.height);
    NSAssert([self size:imageProvider.magicButtonIcon.size equals:defaultEditorImageProvider.magicButtonIcon.size] == YES, @"magicButtonIcon image must have a size of %f x %f",defaultEditorImageProvider.magicButtonIcon.size.width, defaultEditorImageProvider.magicButtonIcon.size.height);
    NSAssert([self size:imageProvider.magicActiveButtonIcon.size equals:defaultEditorImageProvider.magicActiveButtonIcon.size] == YES, @"magicActiveButtonIcon image must have a size of %f x %f",defaultEditorImageProvider.magicActiveButtonIcon.size.width, defaultEditorImageProvider.magicActiveButtonIcon.size.height);
    NSAssert([self size:imageProvider.textIcon.size equals:defaultEditorImageProvider.textIcon.size] == YES, @"textIcon image must have a size of %f x %f",defaultEditorImageProvider.textIcon.size.width, defaultEditorImageProvider.textIcon.size.height);
    NSAssert([self size:imageProvider.bottomBarForEditorImage.size equals:defaultEditorImageProvider.bottomBarForEditorImage.size] == YES, @"bottomBarForEditorImage image must have a size of %f x %f",defaultEditorImageProvider.bottomBarForEditorImage.size.width, defaultEditorImageProvider.bottomBarForEditorImage.size.height);
    NSAssert([self size:imageProvider.brightnessIcon.size equals:defaultEditorImageProvider.brightnessIcon.size] == YES, @"brightnessIcon image must have a size of %f x %f",defaultEditorImageProvider.brightnessIcon.size.width, defaultEditorImageProvider.brightnessIcon.size.height);
    NSAssert([self size:imageProvider.contrastIcon.size equals:defaultEditorImageProvider.contrastIcon.size] == YES, @"contrastIcon image must have a size of %f x %f",defaultEditorImageProvider.contrastIcon.size.width, defaultEditorImageProvider.contrastIcon.size.height);
    NSAssert([self size:imageProvider.cropDragPointImage.size equals:defaultEditorImageProvider.cropDragPointImage.size] == YES, @"cropDragPointImage image must have a size of %f x %f",defaultEditorImageProvider.cropDragPointImage.size.width, defaultEditorImageProvider.cropDragPointImage.size.height);
    NSAssert([self size:imageProvider.customRatioIcon.size equals:defaultEditorImageProvider.customRatioIcon.size] == YES, @"customRatioIcon image must have a size of %f x %f",defaultEditorImageProvider.customRatioIcon.size.width, defaultEditorImageProvider.customRatioIcon.size.height);
    NSAssert([self size:imageProvider.filterIcon.size equals:defaultEditorImageProvider.filterIcon.size] == YES, @"filterIcon image must have a size of %f x %f",defaultEditorImageProvider.filterIcon.size.width, defaultEditorImageProvider.filterIcon.size.height);
    NSAssert([self size:imageProvider.flipHorizontalIcon.size equals:defaultEditorImageProvider.flipHorizontalIcon.size] == YES, @"flipHorizontalIcon image must have a size of %f x %f",defaultEditorImageProvider.flipHorizontalIcon.size.width, defaultEditorImageProvider.flipHorizontalIcon.size.height);
    NSAssert([self size:imageProvider.flipVerticalIcon.size equals:defaultEditorImageProvider.flipVerticalIcon.size] == YES, @"flipVerticalIcon image must have a size of %f x %f",defaultEditorImageProvider.flipVerticalIcon.size.width, defaultEditorImageProvider.flipVerticalIcon.size.height);
    NSAssert([self size:imageProvider.focusAnchorImage.size equals:defaultEditorImageProvider.focusAnchorImage.size] == YES, @"focusAnchorImage image must have a size of %f x %f",defaultEditorImageProvider.focusAnchorImage.size.width, defaultEditorImageProvider.focusAnchorImage.size.height);
    NSAssert([self size:imageProvider.fourToThreeRatioIcon.size equals:defaultEditorImageProvider.fourToThreeRatioIcon.size] == YES, @"fourToThreeRatioIcon image must have a size of %f x %f",defaultEditorImageProvider.fourToThreeRatioIcon.size.width, defaultEditorImageProvider.fourToThreeRatioIcon.size.height);
    NSAssert([self size:imageProvider.gradientImage.size equals:defaultEditorImageProvider.gradientImage.size] == YES, @"gradientImage image must have a size of %f x %f",defaultEditorImageProvider.gradientImage.size.width, defaultEditorImageProvider.gradientImage.size.height);
    NSAssert([self size:imageProvider.linearFocusIcon.size equals:defaultEditorImageProvider.linearFocusIcon.size] == YES, @"linearFocusIcon image must have a size of %f x %f",defaultEditorImageProvider.linearFocusIcon.size.width, defaultEditorImageProvider.linearFocusIcon.size.height);
    NSAssert([self size:imageProvider.radialFocusIcon.size equals:defaultEditorImageProvider.radialFocusIcon.size] == YES, @"radialFocusIcon image must have a size of %f x %f",defaultEditorImageProvider.radialFocusIcon.size.width, defaultEditorImageProvider.radialFocusIcon.size.height);
    NSAssert([self size:imageProvider.noiseIcon.size equals:defaultEditorImageProvider.noiseIcon.size] == YES, @"noiseIcon image must have a size of %f x %f",defaultEditorImageProvider.noiseIcon.size.width, defaultEditorImageProvider.noiseIcon.size.height);
    NSAssert([self size:imageProvider.orientationIcon.size equals:defaultEditorImageProvider.orientationIcon.size] == YES, @"orientationIcon image must have a size of %f x %f",defaultEditorImageProvider.orientationIcon.size.width, defaultEditorImageProvider.orientationIcon.size.height);
    NSAssert([self size:imageProvider.oneToOneRatioIcon.size equals:defaultEditorImageProvider.oneToOneRatioIcon.size] == YES, @"oneToOneRatioIcon image must have a size of %f x %f",defaultEditorImageProvider.oneToOneRatioIcon.size.width, defaultEditorImageProvider.oneToOneRatioIcon.size.height);
    NSAssert([self size:imageProvider.saturationIcon.size equals:defaultEditorImageProvider.saturationIcon.size] == YES, @"saturationIcon image must have a size of %f x %f",defaultEditorImageProvider.saturationIcon.size.width, defaultEditorImageProvider.saturationIcon.size.height);
    NSAssert([self size:imageProvider.sixteenToNineRatioIcon.size equals:defaultEditorImageProvider.sixteenToNineRatioIcon.size] == YES, @"orientationIcon image must have a size of %f x %f",defaultEditorImageProvider.sixteenToNineRatioIcon.size.width, defaultEditorImageProvider.sixteenToNineRatioIcon.size.height);
}

#pragma mark - helper
- (BOOL)size:(CGSize)size1 equals:(CGSize)size2 {
    return ((size1.width == size2.width) && (size1.height == size2.height));
}

@end
