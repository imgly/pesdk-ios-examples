//
//  IMGLYEditorViewController.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorViewController.h"

#import "IMGLYAvailableFilterListProvider.h"
#import "IMGLYDefaultEditorImageProvider.h"
#import "IMGLYDeviceDetector.h"
#import "IMGLYEditorBrightnessViewController.h"
#import "IMGLYEditorContrastViewController.h"
#import "IMGLYEditorCropViewController.h"
#import "IMGLYEditorEnhancementViewController.h"
#import "IMGLYEditorFilterViewController.h"
#import "IMGLYEditorMainMenuView.h"
#import "IMGLYEditorSaturationViewController.h"
#import "IMGLYEnhancementOperation.h"
#import "IMGLYFilterOperation.h"
#import "IMGLYOpenGLUtils.h"
#import "IMGLYPhotoProcessor.h"
#import "IMGLYProcessingJob.h"
#import "SVProgressHUD.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "UINavigationController+IMGLYAdditions.h"

static const CGFloat kEditorMainMenuViewHeight = 95;

@interface IMGLYEditorViewController () <IMGLYEditorMainMenuDelegate, IMGLYAvailableFilterListProvider>

@property (nonatomic, strong) IMGLYEditorMainMenuView *editorMainMenuView;
@property (nonatomic, strong) UIImageView *imagePreview;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) IMGLYProcessingJob *finalProcessingJob;
@property (nonatomic, strong) UIImage *previewImage; // lo resolution used to preview the job
@property (nonatomic, strong) UIImage *enhancedImage; // lo resolution used to preview the job
@property (nonatomic, strong) UIImage *nonEnhancedImage; // lo resolution used to preview the job
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, readonly) dispatch_queue_t contextQueue;

@end

#pragma mark -

@implementation IMGLYEditorViewController

#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        [self commonInit];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        [self commonInit];

    return self;
}

- (void)commonInit {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationController.navigationBar.translucent = NO;
    }

    self.title = @"Editor";

    _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    _contextQueue = dispatch_queue_create("ly.img.finalImageQueue", NULL);
    _finalProcessingJob = [[IMGLYProcessingJob alloc] init];
}

#pragma mark UI Configuration

- (void)configureBackground {
    CGFloat white = 34.0 / 255;
    self.view.backgroundColor = [UIColor colorWithWhite:white alpha:1];
}

- (void)configureMainMenu {
    self.editorMainMenuView = [[IMGLYEditorMainMenuView alloc] initWithFrame:CGRectZero];
    self.editorMainMenuView.menuDelegate = self;
    self.editorMainMenuView.userInteractionEnabled = YES;
    [self.view addSubview:self.editorMainMenuView];
}

- (void)configureBottomBackgoundView {
    self.bottomImageView = [[UIImageView alloc] initWithImage:[_imageProvider bottomBarForEditorImage]];
    [self.view addSubview:self.bottomImageView];
}

- (void)configurePreview {
    self.imagePreview = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    self.imagePreview.image = self.previewImage;
    [self.view addSubview:self.imagePreview];
}

- (void)configureDoneButton {
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(doneButtonTouchedUpInside:)];
    self.doneButton.width = 100;
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)configureBackButton {
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(backButtonTouchedUpInside:)];
    self.backButton.width = 100;
    self.navigationItem.leftBarButtonItem = self.backButton;
}

#pragma mark - system events
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBackground];
    [self configurePreview];
    [self configureBottomBackgoundView];
    [self configureMainMenu];
    [self configureDoneButton];
    [self configureBackButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self hideStatusBar];
    [self layoutBottomImage];
    [self layoutMainMenu];
    [self layoutPreview];
}

#pragma mark Layouting
- (void)layoutMainMenu  {
    self.editorMainMenuView.frame = CGRectMake(0.0,
                                               self.view.frame.size.height - kEditorMainMenuViewHeight,
                                               self.view.frame.size.width,
                                               kEditorMainMenuViewHeight);
}

- (void)layoutBottomImage {
    self.bottomImageView.frame = CGRectMake(0.0,
                                            self.view.frame.size.height - kEditorMainMenuViewHeight,
                                            self.view.frame.size.width,
                                            kEditorMainMenuViewHeight);
}

- (void)layoutPreview {
    self.imagePreview.frame = CGRectMake(0.0,
                                         0.0,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height - kEditorMainMenuViewHeight);
}

-(UIImage *) resizeInputImageIfNeeded: (UIImage*) image maximalSideLength:(NSInteger)maximalSideLength {
    // resize if needed
    if(image.size.width > maximalSideLength || image.size.height > maximalSideLength) {
        double scale = 1.0;
        if(image.size.width > image.size.height) {
            scale = (double)maximalSideLength / (double)image.size.width;
        }
        else {
            scale = (double)maximalSideLength / (double)image.size.height;
        }
        image = [image imgly_resizedImage: CGSizeMake(roundf( image.size.width * scale) , roundf(image.size.height * scale))interpolationQuality:kCGInterpolationDefault];
    }
    return image;
}

#pragma mark - Getter/Setter/Resetter

- (void)setInputImage:(UIImage *)inputImage {
    _inputImage = [inputImage imgly_rotateImageToMatchOrientation];

    if (self.finalProcessingJob.operations.count == 0) {
        self.previewImage = [self resizeInputImageIfNeeded:inputImage maximalSideLength:1136];
    }
    else {
        [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:[self resizeInputImageIfNeeded:inputImage maximalSideLength:1136]];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:self.finalProcessingJob];
        self.previewImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
    }

    self.imagePreview.image = self.previewImage;
}

- (void)setFilterType:(IMGLYFilterType)filterType {
    _filterType = filterType;
    [self addJobForInitialFilterType:filterType];
}

- (void)addJobForInitialFilterType:(IMGLYFilterType)filterType {
    IMGLYFilterOperation *operation = [[IMGLYFilterOperation alloc] init];
    operation.filterType = filterType;
    [_finalProcessingJob addOperation:(IMGLYOperation *)operation];
}

- (void)resetAllChanges {
    self.finalProcessingJob = [[IMGLYProcessingJob alloc] init];
    self.previewImage = [self resizeInputImageIfNeeded:self.inputImage maximalSideLength:480];
    self.imagePreview.image = self.previewImage ;
}

#pragma mark - menu event handling
- (void)mainMenuButtonTouchedUpInsideWithViewControllerClass:(Class)viewControllerClass {
    if ([IMGLYEditorEnhancementViewController class] == viewControllerClass) {
        [self createEnhancedImage];
    }
    else {
        IMGLYAbstractEditorBaseViewController *viewController = [[viewControllerClass alloc] initWithImageProvider:self.imageProvider];
        viewController.inputImage = self.previewImage;
        viewController.completionHandler=^(IMGLYEditorViewControllerResult result, UIImage *outputImage, IMGLYProcessingJob *job){
            [self completedEditigWithResult:result outputImage:outputImage job:job];
        };
        [self.navigationController imgly_pushFadeViewController:viewController];
    }
}

#pragma mark - sub-editor completion handler
- (void)completedEditigWithResult:(IMGLYEditorViewControllerResult)result outputImage:(UIImage *)outputImage job:(IMGLYProcessingJob *)job {
    [self hideStatusBar];
    if (outputImage) {
        self.enhancedImage = nil;
        self.previewImage = outputImage;
        self.imagePreview.image = self.previewImage;
    }
    
    for (IMGLYOperation *operation in job.operations) {
        [self.finalProcessingJob addOperation:operation];
    }
}

#pragma mark - own completion handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [SVProgressHUD showWithStatus:@"Processing"];

    __weak IMGLYEditorViewController *weakSelf = self;
    dispatch_async(_contextQueue, ^{
        IMGLYEditorViewController *strongSelf = weakSelf;
        NSInteger maximaleSideLength = [IMGLYOpenGLUtils maximumTextureSizeForThisDevice];
        NSLog(@"maximaleSideLength %d", maximaleSideLength);
        UIImage *image = [strongSelf resizeInputImageIfNeeded:strongSelf.inputImage
                                      maximalSideLength:maximaleSideLength];
        [IMGLYPhotoProcessor sharedPhotoProcessor].inputImage = image;
        [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:strongSelf.finalProcessingJob];
        UIImage *outputImage = [IMGLYPhotoProcessor sharedPhotoProcessor].outputImage;

        // Clean up
        _inputImage = nil;
        _previewImage = nil;

        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [strongSelf completeWithResult:IMGLYEditorViewControllerResultDone image:outputImage job:strongSelf.finalProcessingJob];
        });
    });
}

- (void)backButtonTouchedUpInside:(UIButton *)button {
    [self completeWithResult:IMGLYEditorViewControllerResultCancelled image:nil job:nil];
}

- (NSArray *)provideAvailableFilterList {
    return self.availableFilterList;
}

- (void)completeWithResult:(IMGLYEditorViewControllerResult)result
                     image:(UIImage *)image
                       job:(IMGLYProcessingJob *)job {

    if (self.completionHandler)
        self.completionHandler(result, image, job);
}

#pragma mark - status bar hiding
- (void)hideStatusBar {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationController.navigationBar.translucent = NO;
    } else
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - image enhancement / magic
- (void)toggleEnhancedImageAndPresentIt {
    if (self.previewImage == self.enhancedImage) {
        self.previewImage = self.nonEnhancedImage;
        [self.editorMainMenuView setMagicInActive];
    }
    else {
        self.previewImage = self.enhancedImage;
        [self.editorMainMenuView setMagicActive];
    }
    self.imagePreview.image = self.previewImage;
    [self hideStatusBar];
}

- (void)createEnhancedImage {
    if (self.enhancedImage == nil) {
        [SVProgressHUD showWithStatus:@"Processing"];
        [self hideStatusBar];
        
        __weak IMGLYEditorViewController *weakSelf = self;
        dispatch_async(_contextQueue, ^{
            IMGLYEditorViewController *strongSelf = weakSelf;
            strongSelf.nonEnhancedImage = strongSelf.previewImage;
            IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
            IMGLYEnhancementOperation *enhancementOperation = [[IMGLYEnhancementOperation alloc] init];

            [job addOperation:(IMGLYOperation *)enhancementOperation];
            [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:strongSelf.nonEnhancedImage];
            [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job ];
            strongSelf.enhancedImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [strongSelf toggleEnhancedImageAndPresentIt];
            });
        });
    }
    else {
        [self toggleEnhancedImageAndPresentIt];
    }

}

@end
