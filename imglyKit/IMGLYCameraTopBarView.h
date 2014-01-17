//
//  IMGLYCameraTopBarView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 13.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCameraController.h"

#import <UIKit/UIKit.h>

@protocol IMGLYCameraTopBarViewDelegate;
@protocol IMGLYCameraImageProvider;

@interface IMGLYCameraTopBarView : UIView

@property (nonatomic, weak) id<IMGLYCameraTopBarViewDelegate> delegate;

- (void)hideFlashButton;
- (void)showFlashButton;
- (void)hideCameraToggleButton;
- (void)showCameraToggleButton;

- (instancetype)initWithYPosition:(CGFloat)yPosition;

- (instancetype)initWithYPosition:(CGFloat)yPosition imageProvider:(id <IMGLYCameraImageProvider>)imageProvider;

- (void)rotateForPortraitOrientation:(BOOL)isFilterSelectorDown;
- (void)rotateForLandscapeLeftOrientation:(BOOL)isFilterSelectorDown;
- (void)rotateForLandscapeRightOrientation:(BOOL)isFilterSelectorDown;
- (void)relayoutForFilterSelectorStatus:(BOOL)isFilterSelectorDown;

@end

#pragma mark -

@protocol IMGLYCameraTopBarViewDelegate <NSObject>
@optional

- (void)cameraTopBarView:(IMGLYCameraTopBarView *)cameraTopBarView
        didSelectCameraFlashMode:(IMGLYCameraFlashMode)cameraFlashMode;

- (void)cameraTopBarViewDidToggleCameraPosition:(IMGLYCameraTopBarView *)cameraTopBarView;

@end
