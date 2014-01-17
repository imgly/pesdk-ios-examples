//
//  IMGLYEditorContrastController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorContrastViewController.h"

#import "IMGLYContrastOperation.h"
#import "IMGLYPhotoProcessor.h"
#import "IMGLYProcessingJob.h"

#import "UINavigationController+IMGLYAdditions.h"
#import "UIImage+IMGLYKitAdditions.h"

extern CGFloat kSliderheight;
extern CGFloat kSliderXMargin;

@interface IMGLYEditorContrastViewController()

@property UISlider *slider;

@end

@implementation IMGLYEditorContrastViewController

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
    self.title = @"Contrast";
    [self configureSlider];
}

- (void)configureSlider {
    _slider = [[UISlider alloc] init];
    _slider.minimumValue = 0.3;
    _slider.maximumValue = 1.7;
    _slider.value = 1;
    _slider.continuous = YES;
    _slider.minimumValueImage = [UIImage imgly_imageNamed:@"slider_minus"];
    _slider.maximumValueImage = [UIImage imgly_imageNamed:@"slider_plus"];
    [_slider addTarget:self action:@selector(controlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
}

#pragma mark - layout
- (void)layoutSlider {
    // we put the slider y to the half of the menu - the half of the slider height.
    // that way its centred y-wise
    self.slider.frame = CGRectMake(kSliderXMargin,
                                   self.view.frame.size.height - self.editMenuHeight / 2.0 - kSliderheight / 2.0,
                                   self.view.frame.size.width - 2.0 * kSliderXMargin,
                                   kSliderheight);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutSlider];
}

-(void)controlValueChanged:(id)sender{
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYContrastOperation *operation = [[IMGLYContrastOperation alloc] init];
    operation.contrast = self.slider.value;
    [job addOperation:(IMGLYOperation *)operation];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.imagePreview.image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}


#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYContrastOperation *operation = [[IMGLYContrastOperation alloc] init];
    operation.contrast = self.slider.value;
    [job addOperation:(IMGLYOperation *)operation];
    self.completionHandler(IMGLYEditorViewControllerResultDone,self.imagePreview.image, job);
}
@end
