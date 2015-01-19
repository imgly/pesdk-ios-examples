//
//  IMGLYEditorNoiseViewController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 03.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorNoiseViewController.h"

#import "IMGLYNoiseOperation.h"
#import "IMGLYPhotoProcessor.h"
#import "IMGLYProcessingJob.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "UINavigationController+IMGLYAdditions.h"

extern CGFloat kSliderheight ;
extern CGFloat kSliderXMargin ;
const static CGFloat kMaximumNoiseValue = 0.25;

@interface IMGLYEditorNoiseViewController()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIImage *noiseImage;
@property (nonatomic, strong) UIImage *maximumEffectImage;
@property (nonatomic, strong) UIImageView *maximumEffectPreview;

@end

@implementation IMGLYEditorNoiseViewController

#pragma mark - init
- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    [self commonInit];
    return self;
}

- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithImageProvider:imageProvider];
    if (self == nil)
        return nil;
    [self commonInit];
    return self;
}

#pragma mark - GUI configuration
- (void)commonInit {
    self.title = @"Noise";
    [self configureSlider];
    [self configureNoiseImage];
    [self configureMaximumEffectPreview];
}

- (void)configureMaximumEffectPreview {
    _maximumEffectPreview = [[UIImageView alloc] initWithFrame:CGRectZero];
    _maximumEffectPreview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _maximumEffectPreview.alpha = 0.0;
    _maximumEffectPreview.frame = self.imagePreview.frame;
    _maximumEffectPreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.previewScrollView addSubview:_maximumEffectPreview];
}

- (void)configureNoiseImage {
//    _noiseImage = [UIImage imgly_imageNamed:@"noise512.png"];
}

- (void)configureSlider {
    _slider = [[UISlider alloc] init];
    _slider.minimumValue = 0;
    _slider.maximumValue = 1;
    _slider.value = 0;
    _slider.continuous = YES;
    _slider.minimumValueImage = [UIImage imgly_imageNamed:@"slider_minus"];
    _slider.maximumValueImage = [UIImage imgly_imageNamed:@"slider_plus"];
    [_slider addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutSlider];
    [self layoutMaximumEffectPreview];
}

- (void)layoutMaximumEffectPreview {
    self.maximumEffectPreview.frame = self.imagePreview.frame;
}

- (void)layoutSlider {
    // we put the slider y to the half of the menu - the half of the slider height.
    // that way its centred y-wise
    self.slider.frame = CGRectMake(kSliderXMargin,
                                   self.view.frame.size.height - self.editMenuHeight / 2.0 - kSliderheight / 2.0,
                                   self.view.frame.size.width - 2.0 * kSliderXMargin,
                                   kSliderheight);
}

#pragma mark - preview update
-(void)controlValueChanged:(id)sender{
    if(self.maximumEffectImage == nil) {
        [self generateAndSetMaximumEffectImage];
    }
    self.maximumEffectPreview.alpha = self.slider.value;
}

#pragma mark - processing

- (void)generateAndSetMaximumEffectImage {
    IMGLYProcessingJob *job = [self processingJobForValue:kMaximumNoiseValue];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.maximumEffectImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
    self.maximumEffectPreview.image = self.maximumEffectImage;
    self.maximumEffectPreview.frame = self.imagePreview.frame;
    self.maximumEffectPreview.contentMode = self.imagePreview.contentMode;
}

- (IMGLYProcessingJob *)processingJobForValue:(CGFloat)value {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYNoiseOperation *operation = [[IMGLYNoiseOperation alloc] init];
    operation.intensity = value;
    operation.noiseImage = self.noiseImage;
    [job addOperation:(IMGLYOperation *)operation];
    return job;
}

- (IMGLYProcessingJob *)processingJobWihoutNoiseImageSetForValue:(CGFloat)value {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYNoiseOperation *operation = [[IMGLYNoiseOperation alloc] init];
    operation.intensity = value;
    operation.noiseImage = nil;
    [job addOperation:(IMGLYOperation *)operation];
    return job;
}


- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
        CGFloat noiseValue = kMaximumNoiseValue * self.slider.value;
        IMGLYProcessingJob *job = [self processingJobForValue:noiseValue];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
        UIImage *image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];

        // the final job has the noise image set to nil , so we force recalculation
        self.completionHandler(IMGLYEditorViewControllerResultDone, image, [self processingJobWihoutNoiseImageSetForValue:noiseValue]);
    }
}

// we handle our zoom on ourselfs
#pragma mark - zoom

- (void) zoomImagePreviewIn {
    CGSize displayedImageSize = [self scaledImageSize];
    CGFloat scaleFactor = self.previewScrollView.frame.size.width / displayedImageSize.width;
    CGFloat yOffset = (displayedImageSize.height * scaleFactor - displayedImageSize.height) / 2.0;
    CGFloat xOffset = 0.0;
    if (displayedImageSize.width >= self.previewScrollView.frame.size.width) {
        scaleFactor = self.previewScrollView.frame.size.height / displayedImageSize.height;
        xOffset = (displayedImageSize.width * scaleFactor - displayedImageSize.width) / 2.0;
        yOffset = 0.0;
    }
    self.previewScrollView.contentSize = CGSizeMake(displayedImageSize.width * scaleFactor,
                                                    displayedImageSize.height * scaleFactor);
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.imagePreview.frame = CGRectMake(0,
                                                              0,
                                                              self.previewScrollView.contentSize.width,
                                                              self.previewScrollView.contentSize.height);
                         self.maximumEffectPreview.frame = self.imagePreview.frame;
                         self.previewScrollView.contentOffset = CGPointMake(xOffset, yOffset);
                     }
                     completion:^(BOOL finished) {
                         self.previewZoomed = YES;
                     }];
}

- (void) zoomImagePreviewOut {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.imagePreview.frame = self.previewScrollView.frame;
                         self.maximumEffectPreview.frame = self.imagePreview.frame;
                         self.previewScrollView.contentSize = self.imagePreview.frame.size;
                         self.previewScrollView.contentOffset = CGPointMake(0,0);
                     }
                     completion:^(BOOL finished) {
                         self.previewZoomed = NO;
                     }];
}

@end
