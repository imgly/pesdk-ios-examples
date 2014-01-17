//
//  IMGLYCameraBottomBarView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 12.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCameraBottomBarView.h"

#import "IMGLYDefaultCameraImageProvider.h"
#import "IMGLYDeviceDetector.h"
#import "UIImage+IMGLYKitAdditions.h"

#import <QuartzCore/QuartzCore.h>

@interface IMGLYCameraBottomBarView ()

@property (nonatomic, assign) CGFloat bottomImageY;
@property (nonatomic, strong) UIImageView *bottomBackgroundView;
@property (nonatomic, strong) UIImageView *smallbottomBackgroundView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *selectFromRollButton;
@property (nonatomic, strong) UIButton *toggleFilterSelectorButton;
@property (nonatomic, strong) UIButton *rightToogleFilterSelectorButton;
@property (nonatomic, strong) UIImage *bottomImage;
@property (nonatomic, strong) id<IMGLYCameraImageProvider> imageProvider;

@end

#pragma mark -

@implementation IMGLYCameraBottomBarView

#pragma mark - init and config

- (instancetype)initWithYPosition:(CGFloat)yPosition {
    self = [super init];
    if (self) {
        _bottomImageY = yPosition;
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithYPosition:(CGFloat)yPosition imageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    self = [super init];
    if (self) {
        _bottomImageY = yPosition;
        _imageProvider = imageProvider;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    if  (_imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    }

    [self configureFrame];
    [self configureBottomBackgroundView];
    [self configureTakePhotoButton];
    [self configureSelectFromRollButton];
    [self configureToggleFilterSelectorButton];
    [self configureRightToggleFilterSelectorButton];
}

- (void)configureFrame {
    if ([IMGLYDeviceDetector isRunningOn4Inch])
        _bottomImage = [self.imageProvider bottomBarForCamera4InchImage];
    else
        _bottomImage = [self.imageProvider bottomBarForCamera3_5InchImage];

    UIImage *gradientImage = [self.imageProvider gradientImage];
    CGSize bottomImageSize = _bottomImage.size;
    self.frame = CGRectMake(0,
                            _bottomImageY - bottomImageSize.height,
                            bottomImageSize.width * 2,
                            bottomImageSize.height + gradientImage.size.height);
}

- (void)configureBottomBackgroundView {
    _bottomBackgroundView = [[UIImageView alloc] initWithImage:_bottomImage];
    _bottomBackgroundView.frame = CGRectMake(0, 0, _bottomImage.size.width , _bottomImage.size.height);
    [self addSubview:_bottomBackgroundView];
}

- (void)configureTakePhotoButton {
    _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cameraImage = [self.imageProvider cameraButtonImage];
    [_takePhotoButton setImage:cameraImage forState:UIControlStateNormal];
    _takePhotoButton.frame = CGRectMake(160 - cameraImage.size.width / 2,
                                        _bottomImage.size.height / 2 - cameraImage.size.height / 2,
                                        cameraImage.size.width,
                                        cameraImage.size.height);
    [_takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_takePhotoButton];
}

- (void)configureSelectFromRollButton {
    _selectFromRollButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [self.imageProvider selectFromCameraRollImage];
    [_selectFromRollButton setImage:image forState:UIControlStateNormal];
    [_selectFromRollButton addTarget:self
                              action:@selector(selectFromCameraRoll)
                    forControlEvents:UIControlEventTouchUpInside];
    CGFloat height = _bottomImage.size.height / 2 - _selectFromRollButton.imageView.image.size.height / 2;
    _selectFromRollButton.frame = CGRectMake(15, height, 40, 40);
    [self addSubview:_selectFromRollButton];
}

- (void)configureToggleFilterSelectorButton {
    _toggleFilterSelectorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [self.imageProvider filterSelectorArrowUpImage];
    [_toggleFilterSelectorButton setImage:image  forState:UIControlStateNormal];
    [_toggleFilterSelectorButton addTarget:self
                                    action:@selector(toggleFilterSelector)
                          forControlEvents:UIControlEventTouchUpInside];
    CGFloat height = _bottomImage.size.height / 2 - _toggleFilterSelectorButton.imageView.image.size.height / 2;
    _toggleFilterSelectorButton.frame = CGRectMake(320 - 36 - 15, height, 40, 40);
    [self addSubview:_toggleFilterSelectorButton];
}

- (void)configureRightToggleFilterSelectorButton {
    _rightToogleFilterSelectorButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [self.imageProvider filterSelectorArrowUpImage];
    [_rightToogleFilterSelectorButton setImage:image forState:UIControlStateNormal];
    [_rightToogleFilterSelectorButton addTarget:self
                                         action:@selector(toggleFilterSelector)
                               forControlEvents:UIControlEventTouchUpInside];
    UIImage *bottomImage = [self.imageProvider bottomBarForCamera3_5InchImage];
    CGFloat buttonHeight = bottomImage.size.width + 320 - 36 - 15;

    CGFloat height = _bottomImage.size.height / 2 - _rightToogleFilterSelectorButton.imageView.image.size.height / 2;
    _rightToogleFilterSelectorButton.frame = CGRectMake(buttonHeight, height, 40, 40);
    [self addSubview:_rightToogleFilterSelectorButton];
}

#pragma mark - button delegation
- (void)takePhoto {
    [self.delegate takePhoto];
}

- (void)selectFromCameraRoll {
    [self.delegate selectFromCameraRoll];
}

- (void)toggleFilterSelector {
    [self.delegate toggleFilterSelector];
}

#pragma mark - arrow direction handling
- (void)setArrowDirectionDown {
    [self.toggleFilterSelectorButton setImage:[self.imageProvider filterSelectorArrowDownImage]
                                     forState:UIControlStateNormal];
    [self.rightToogleFilterSelectorButton setImage:[self.imageProvider filterSelectorArrowDownImage]
                                          forState:UIControlStateNormal];
}

- (void)setArrowDirectionUp {
    [self.toggleFilterSelectorButton setImage:[self.imageProvider filterSelectorArrowUpImage]
                                     forState:UIControlStateNormal];
    [self.rightToogleFilterSelectorButton setImage:[self.imageProvider filterSelectorArrowUpImage] 
                                          forState:UIControlStateNormal];
}

#pragma mark - button control
- (void)setAlphaForAllViews:(CGFloat)alpha {
    self.bottomBackgroundView.alpha = alpha;
}

- (void)enableAllButtons {
    self.takePhotoButton.enabled = YES;
    self.selectFromRollButton.enabled = YES;
    self.toggleFilterSelectorButton.enabled = YES;
}

- (void)disableAllButtons {
    self.takePhotoButton.enabled = NO;
    self.selectFromRollButton.enabled = NO;
    self.toggleFilterSelectorButton.enabled = NO;
}

#pragma mark - rotation
- (void)rotateForPortraitOrientation {
    [self setRotationForButtons:0.0];
}

- (void)rotateForLandscapeLeftOrientation {
    CGFloat angle = M_PI / 2.0;
    [self setRotationForButtons:angle];
}

- (void)rotateForLandscapeRightOrientation {
    CGFloat angle = -M_PI / 2.0;
    [self setRotationForButtons:angle];
}

- (void)setRotationForButtons:(CGFloat)angle {
    self.takePhotoButton.transform = CGAffineTransformMakeRotation(angle);
    self.selectFromRollButton.transform = CGAffineTransformMakeRotation(angle);
}

- (CGFloat)backgroundAlpha {
    return self.bottomBackgroundView.alpha;
}

@end
