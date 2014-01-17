//
//  IMGLYCameraController.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 07.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IMGLYCameraPosition) {
    IMGLYCameraPositionUnkown = 0,
    IMGLYCameraPositionFront,
    IMGLYCameraPositionBack
};

typedef NS_ENUM(NSInteger, IMGLYCameraFlashMode) {
    IMGLYCameraFlashModeUnkown = 0,
    IMGLYCameraFlashModeOn,
    IMGLYCameraFlashModeOff,
    IMGLYCameraFlashModeAuto
};

@interface IMGLYCameraController : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) IMGLYCameraPosition cameraPosition;
@property (nonatomic, assign) IMGLYCameraFlashMode cameraFlashMode;
@property (nonatomic, assign) BOOL cameraSupportsFlash;

- (instancetype)initWithRect:(CGRect)rect;

- (void)addGestureRecogizerToStreamPreview:(UIGestureRecognizer *)gestureRecognizer;

- (void)addNotifications;

- (void)onSingleTapFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                 forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)onDoubleTapFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                 forInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;

- (void)startCameraCapture;
- (void)stopCameraCapture;
- (void)pauseCameraCapture;
- (void)resumeCameraCapture;

- (void)selectFilterType:(IMGLYFilterType)filterType;
- (IMGLYFilterType)filterType;
- (void)flipCamera;

- (void)takePhotoWithCompletionHandler:(void (^)(UIImage *processedImage, NSError *error))completionHandler;
- (void)setPreviewAlpha:(CGFloat)alpha;

- (void)hideIndicator;

- (BOOL)cameraSupportsFlash;

- (void)removeNotifications;

- (void)addCameraObservers;
- (void)removeCameraObservers;

- (void)hideStreamPreview;
- (void)showStreamPreview;

@end
