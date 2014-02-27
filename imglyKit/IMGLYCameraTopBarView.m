//
//  IMGLYCameraTopBarView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 13.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCameraTopBarView.h"

#import "IMGLYDeviceDetector.h"

#import "UIImage+IMGLYKitAdditions.h"
#import "IMGLYDefaultCameraImageProvider.h"


static const CGFloat kIMGLYUpperBarY = 11.0f;
extern CGFloat filterSelectorMoveDistance;


@interface IMGLYCameraTopBarView ()

@property (nonatomic, assign) CGFloat yPosition;
@property (nonatomic, strong) UIButton *toggleCameraButton;
@property (nonatomic, strong) UIButton *flashSelectorButton;
@property (nonatomic, strong) UILabel *flashModeLabel;
@property (nonatomic, assign) IMGLYCameraFlashMode cameraFlashMode;
@property (nonatomic, strong) id<IMGLYCameraImageProvider> imageProvider;

@end

@implementation IMGLYCameraTopBarView

#pragma mark configuration / init

- (instancetype)initWithYPosition:(CGFloat)yPosition {
    self = [super init];
    if (self) {
        _imageProvider = nil;
        _yPosition = kIMGLYUpperBarY;
        [self configureUserInterface];
    }

    return self;
}

- (instancetype)initWithYPosition:(CGFloat)yPosition imageProvider:(id<IMGLYCameraImageProvider>) imageProvider {
    self = [super init];
    if (self) {
        _imageProvider = imageProvider;
        _yPosition = kIMGLYUpperBarY;
        [self configureUserInterface];
    }
    return self;
}

- (void)configureUserInterface {
    if (_imageProvider == nil) {
       _imageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    }
    self.userInteractionEnabled = YES;
    [self configureSwitchCameraButton];
    [self configureFlashSelectorButton];
    [self configureFlashModeLabel];
    self.cameraFlashMode = IMGLYCameraFlashModeAuto;
}

- (void)configureSwitchCameraButton {
    CGRect frame = CGRectMake(320.0f - 68.0f - 10.0f, self.yPosition, 70.0f, 35.0f);
    _toggleCameraButton = [self addButtonWithImageToViewWithImage:[self.imageProvider swapCameraImage]
                                                        withFrame:frame
                                                           action:@selector(toggleCameraButtonTouchedUpInside:)
                                                           hidden:NO
                                                        superView:self];
    _toggleCameraButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void)configureFlashSelectorButton {
    CGRect frame = CGRectMake(10.0f, self.yPosition, 81.0f, 35.0f);
    _flashSelectorButton = [self addButtonWithImageToViewWithImage:[self.imageProvider toggleFlashImage]
                                                         withFrame:frame
                                                            action:@selector(flashSelectorButtonTouchedUpInside:)
                                                            hidden:NO
                                                         superView:self];
    _flashSelectorButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
}

- (void)configureFlashModeLabel {
    _flashModeLabel = [[UILabel alloc] init];
    _flashModeLabel.text = @"Auto";
    _flashModeLabel.textAlignment = NSTextAlignmentCenter;
    _flashModeLabel.textColor = [UIColor whiteColor];
    _flashModeLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    _flashModeLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    CGRect frame = _flashSelectorButton.frame;
    frame.origin.x += 9.0f;
    _flashModeLabel.frame = frame;
    [self addSubview:_flashModeLabel];
}

- (UIButton *)addButtonWithImageToViewWithImage:(UIImage *)image
                                      withFrame:(CGRect)frame
                                         action:(SEL)action
                                         hidden:(BOOL)hidden
                                      superView:(UIView *)superView {

    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.hidden = hidden;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    return button;
}

#pragma mark - flashmode 

- (void)setCameraFlashMode:(IMGLYCameraFlashMode)cameraFlashMode {
    _cameraFlashMode = cameraFlashMode;
    [self updateFlashLabel];
}

- (void)updateFlashLabel {
    switch (self.cameraFlashMode) {
        case IMGLYCameraFlashModeAuto:
            self.flashModeLabel.text = @"Auto";
            break;
        case IMGLYCameraFlashModeOff:
            self.flashModeLabel.text = @"Off";
            break;
        case IMGLYCameraFlashModeOn:
            self.flashModeLabel.text = @"On";
            break;
        case IMGLYCameraFlashModeUnkown:
            break;
    }
}

- (void)setFlashIsAvailable:(BOOL)flashAvailable {
    self.flashSelectorButton.hidden = !flashAvailable;
    self.flashModeLabel.hidden = !flashAvailable;
}

- (void)setNextFlashMode {
    switch (self.cameraFlashMode) {
        case IMGLYCameraFlashModeAuto:
            self.cameraFlashMode = IMGLYCameraFlashModeOn;
            break;
        case IMGLYCameraFlashModeOff:
            self.cameraFlashMode = IMGLYCameraFlashModeAuto;
            break;
        case IMGLYCameraFlashModeOn:
            self.cameraFlashMode = IMGLYCameraFlashModeOff;
            break;
        case IMGLYCameraFlashModeUnkown:
            break;
    }
}

#pragma mark - button handling
- (void)toggleCameraButtonTouchedUpInside :(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(cameraTopBarViewDidToggleCameraPosition:)])
        [self.delegate cameraTopBarViewDidToggleCameraPosition:self];
}

- (void)flashSelectorButtonTouchedUpInside :(UIButton *)button{
    [self setNextFlashMode];
    if ([self.delegate respondsToSelector:@selector(cameraTopBarView:didSelectCameraFlashMode:)])
        [self.delegate cameraTopBarView:self didSelectCameraFlashMode:self.cameraFlashMode];
}

- (void)hideFlashButton {
    self.flashSelectorButton.hidden = YES;
    self.flashModeLabel.hidden = YES;
}

- (void)showFlashButton {
    self.flashSelectorButton.hidden = NO;
    self.flashModeLabel.hidden = NO;
}

- (void)hideCameraToggleButton {
    self.toggleCameraButton.hidden = YES;
}

- (void)showCameraToggleButton {
    self.toggleCameraButton.hidden = NO;
}

#pragma mark - rotation
- (void)rotateForPortraitOrientation:(BOOL)isFilterSelectorDown {
    [self setRotationForButtons: 0.0];
    [self relayoutForFilterSelectorStatus:isFilterSelectorDown];
}

- (void)rotateForLandscapeRightOrientation:(BOOL)isFilterSelectorDown {
    [self setRotationForButtons: -M_PI / 2.0];
    [self relayoutForFilterSelectorStatus:isFilterSelectorDown];
}

- (void)rotateForLandscapeLeftOrientation:(BOOL)isFilterSelectorDown {
    [self setRotationForButtons: +M_PI / 2.0];
    [self relayoutForFilterSelectorStatus:isFilterSelectorDown];
}

- (void)setRotationForButtons:(CGFloat)angle {
    self.transform = CGAffineTransformMakeRotation(angle);
}

#pragma mark - layout helper
- (void)relayoutForFilterSelectorStatus:(BOOL)isFilterSelectorDown {
    self.frame = [self getViewRect:isFilterSelectorDown];

    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        CGRect toggleCameraButtonFrame = self.toggleCameraButton.frame;
        toggleCameraButtonFrame.origin.x = 242;
        self.toggleCameraButton.frame = toggleCameraButtonFrame;
    }
}

- (CGRect)getViewRect:(BOOL)isFilterSelectorDown {
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    CGFloat heightSubstract = 100;
    if ([IMGLYDeviceDetector isRunningOn4Inch]) {
        heightSubstract = 130;
    }

    if (orientation == UIDeviceOrientationLandscapeRight) {
        if (isFilterSelectorDown) {
            return CGRectMake(self.yPosition, 20, 55, mainScreenBounds.size.height - heightSubstract);
        }
        else {
            return CGRectMake(self.yPosition, 20, 55, mainScreenBounds.size.height - heightSubstract + filterSelectorMoveDistance);
        }
    }
    else if(orientation == UIDeviceOrientationLandscapeLeft) {
        if (isFilterSelectorDown) {
            return CGRectMake(270 - self.yPosition, 20, 55, mainScreenBounds.size.height - heightSubstract);
        }
        else {
            return CGRectMake(270 - self.yPosition, 20, 55, mainScreenBounds.size.height - heightSubstract + filterSelectorMoveDistance);
        }
    }

    return CGRectMake(0, self.yPosition, mainScreenBounds.size.width, 55);
}

@end
