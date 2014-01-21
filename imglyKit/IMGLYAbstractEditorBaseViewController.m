//
// IMGLYAbstractEditorBaseViewController.m
// imglyKit
// 
// Created by Carsten Przyluczky on 24.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYAbstractEditorBaseViewController_Private.h"

#import "IMGLYDefaultEditorImageProvider.h"
#import "IMGLYDefines.h"
#import "IMGLYProcessingJob.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "UINavigationController+IMGLYAdditions.h"

const CGFloat kEditorMenuViewHeight = 95;

@implementation IMGLYAbstractEditorBaseViewController

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;

    [self baseCommonInit];

    return self;
}

- (instancetype)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super init];
    if (!self)
        return nil;

    _imageProvider = imageProvider;
    [self baseCommonInit];

    return self;
}

- (void)baseCommonInit {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        self.automaticallyAdjustsScrollViewInsets = NO;

    if (!_imageProvider)
        _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];

    _previewZoomEnabled = YES;
    _previewZoomed = NO;
    _editMenuHeight = kEditorMenuViewHeight;

    [self configurePreview];
    [self configurePreviewScrollView];
    [self configureBackground];
    [self configureBottomBackgoundView];
    [self addTapGestureRecognizerToImagePreview];
    [self createJob];
}

#pragma mark User Interface

- (void)configurePreview {
    _imagePreview = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    _imagePreview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    if (_inputImage)
        _imagePreview.image = _inputImage;
}

- (void)configureDoneButton {
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(doneButtonTouchedUpInside:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)configurePreviewScrollView {
    _previewScrollView = [[UIScrollView alloc] init];
    [_previewScrollView addSubview:_imagePreview];
    [self.view addSubview:_previewScrollView];
}

- (void)configureBackground {
    CGFloat white = 34.0 / 255;
    self.view.backgroundColor = [UIColor colorWithWhite:white alpha:1];
}

- (void)configureBottomBackgoundView {
    UIImage *image = [self.imageProvider bottomBarForEditorImage];
    _bottomImageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:_bottomImageView];
}

#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideStatusBar];
    [self configureDoneButton];
    [self configureBackButton];
}

#pragma mark Layout

- (void)layoutBottomImage {
    CGSize viewSize = self.view.frame.size;
    CGFloat y = viewSize.height - self.editMenuHeight;
    self.bottomImageView.frame = CGRectMake(0, y, viewSize.width, kEditorMenuViewHeight);
}

- (void)layoutPreview {
    CGSize viewSize = self.view.frame.size;
    CGFloat height = viewSize.height - self.editMenuHeight;
    self.imagePreview.frame = CGRectMake(0, 0, viewSize.width, height);
}

- (void)layoutPreviewScrollView {
    CGSize viewSize = self.view.frame.size;
    CGFloat height = viewSize.height - self.editMenuHeight;
    self.previewScrollView.frame = CGRectMake(0, 0, viewSize.width, height);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutBottomImage];
    [self layoutPreviewScrollView];
    [self layoutPreview];
    [self recalculateImagePreviewBounds];
}

- (void)setInputImage:(UIImage *)inputImage {
    _inputImage = inputImage;
    self.imagePreview.image = inputImage;
    [self recalculateImagePreviewBounds];
}

#pragma mark Gestures

- (void)addTapGestureRecognizerToImagePreview {
    _imagePreview.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer
        = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImagePreviewTap:)];
    tapGestureRecognizer.delegate = self;
    [_imagePreview addGestureRecognizer:tapGestureRecognizer];

    UITapGestureRecognizer *doubleTapGestureRecognizer
        = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImagePreviewDoubleTap:)];
    doubleTapGestureRecognizer.delegate = self;
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_imagePreview addGestureRecognizer:doubleTapGestureRecognizer];
}

- (void)handleImagePreviewTap:(UITapGestureRecognizer *)recognizer {
    if (!self.previewZoomed && self.previewZoomEnabled)
        [self zoomImagePreviewIn];
}

- (void)handleImagePreviewDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (self.previewZoomed && self.previewZoomEnabled)
        [self zoomImagePreviewOut];
}

#pragma mark Zoom

- (void)disableZoomOnTap {
    self.previewZoomEnabled = NO;
}

- (void)zoomImagePreviewIn {
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
    
    [UIView animateWithDuration:0.2 animations:^{
        CGSize contentSize = self.previewScrollView.contentSize;
        self.imagePreview.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
        self.previewScrollView.contentOffset = CGPointMake(xOffset,yOffset);
    } completion:^(BOOL finished) {
        self.previewZoomed = YES;
    }];
}

- (void)zoomImagePreviewOut {
    [UIView animateWithDuration:0.2 animations:^{
        self.imagePreview.frame = self.previewScrollView.frame;
        self.previewScrollView.contentSize = self.imagePreview.frame.size;
        self.previewScrollView.contentOffset = CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        self.previewZoomed = NO;
    }];
}

- (CGSize)scaledImageSize {
    CGFloat widthRatio = self.imagePreview.bounds.size.width / self.imagePreview.image.size.width;
    CGFloat heightRatio = self.imagePreview.bounds.size.height / self.imagePreview.image.size.height;
    CGFloat scale = MIN(widthRatio, heightRatio);
    CGSize size;
    size.width = scale * self.imagePreview.image.size.width;
    size.height = scale * self.imagePreview.image.size.height;
    return size;
}

#pragma mark - done button handling

- (void)doneButtonTouchedUpInside:(UIButton *)button {
    DLog(@"abstract done button touched handler called!, please override it with your own implementation");
}

- (void)showDoneButton {
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)hideDoneButton {
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - job related
- (void)createJob {
    _job = [[IMGLYProcessingJob alloc] init];
}

#pragma mark - tools
- (void)recalculateImagePreviewBounds {
    CGSize scaledImageSize =  [self scaledImageSize];
    self.leftPreviewBound = (self.imagePreview.frame.size.width - scaledImageSize.width) / 2.0;
    self.rightPreviewBound = self.imagePreview.frame.size.width - self.leftPreviewBound;
    self.topPreviewBound = (self.imagePreview.frame.size.height - scaledImageSize.height) / 2.0;
    self.bottomPreviewBound = self.imagePreview.frame.size.height - self.topPreviewBound;
}

- (void)configureBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(backButtonTouchedUpInside:)];
    backButton.width = 100;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)backButtonTouchedUpInside:(UIButton *)button {
    [self.navigationController  imgly_fadePopViewController];
}

#pragma mark - status bar hiding
- (void)hideStatusBar {
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
