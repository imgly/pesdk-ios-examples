//
//  IMGLYCameraViewController.m
//  imglyKit
//
//  Created by Manuel Binna on 06.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCameraViewController.h"

#import "IMGLYCameraBottomBarView.h"
#import "IMGLYCameraController.h"
#import "IMGLYCameraTopBarView.h"
#import "IMGLYDefaultCameraImageProvider.h"
#import "IMGLYDefines.h"
#import "IMGLYDeviceDetector.h"
#import "IMGLYFilterSelectorView.h"
#import "IMGLYImageProviderChecker.h"
#import "IMGLYShutterView.h"
#import "IMGLYDeviceDetector.h"
#import "IMGLYOrientationOperation.h"
#import "UIImage+IMGLYKitAdditions.h"

#import <SVProgressHUD/SVProgressHUD.h>

 CGFloat filterSelectorMoveDistance = -95.0f;
const CGFloat kIMGLYPreviewImageSize = 62.0f;
extern const CGFloat kIMGLYPreviewImageDistance;
static const CGFloat kIMGLYPreviewImageTextHeight = 22.0f;
extern const CGFloat kIMGLYExtraSpaceForScrollBar;
const CGFloat kIMGLYHQProgressWidth = 48;
const CGFloat kIMGLYHQProgressHeight = 58;
const CGFloat kIMGLYHQProgressMarginRight = 10;

@interface IMGLYCameraViewController () <UIGestureRecognizerDelegate,
                                         IMGLYCameraBottomBarCommandDelegate,
                                         IMGLYFilterSelectorViewDelegate,
                                         UINavigationControllerDelegate,
                                         UIImagePickerControllerDelegate,
                                         IMGLYCameraTopBarViewDelegate>

@property (nonatomic, strong) IMGLYCameraBottomBarView *cameraBottomBarView;
@property (nonatomic, strong) IMGLYCameraController *cameraController;
@property (nonatomic, strong) IMGLYCameraTopBarView *cameraTopBarView;
@property (nonatomic, strong) IMGLYFilterSelectorView *filterSelectorView;
@property (nonatomic, strong) IMGLYShutterView *shutterView;
@property (nonatomic, assign) BOOL isFilterSelectorDown;
@property (nonatomic, strong) id<IMGLYCameraImageProvider> imageProvider;
@property (nonatomic, strong) NSArray *availableFilterList;

@end

#pragma mark -

@implementation IMGLYCameraViewController

#pragma mark - init

- (instancetype)initWithCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _imageProvider = imageProvider;
    return self;
}


- (instancetype)initWithCameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider availableFilterList:(NSArray *)list {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _availableFilterList = list;
    _imageProvider = imageProvider;
    return self;
}


- (instancetype)initWithAvailableFilterList:(NSArray *)list {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _availableFilterList = list;
    return self;
}

- (void)viewDidLoad {
    [self hideStatusBar];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.imageProvider == nil) {
        self.imageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    }
    else {
     [[IMGLYImageProviderChecker sharedInstance] checkCameraImageProvider:self.imageProvider];
    }
    
    self.isFilterSelectorDown = YES;
    
    [self configureCameraController];
    [self configureGestureRecognizers];
    
    [self configureCameraBottomBarView];
    [self configureFilterSelectorView];
    [self configureCameraTopBar];
    [self configureShutterView];
    [self addOrientationNotification];
}

- (void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    [self.cameraController startCameraCapture];
    [[self shutterView] openShutter];
}

#pragma mark - GUI configuration

- (void)configureFilterSelectorView {
    CGRect viewBounds = self.view.bounds;
    CGFloat selectorViewHeight = 95;
    CGRect selectorViewFrame = CGRectMake(0.0f, viewBounds.size.height, viewBounds.size.width, selectorViewHeight);
    self.filterSelectorView = [[IMGLYFilterSelectorView alloc] initWithFrame:selectorViewFrame
                                                            previewImageSize:kIMGLYPreviewImageSize
                                                         cameraImageProvider:_imageProvider
                                                         availableFilterList:_availableFilterList];
    self.filterSelectorView.delegate = self;
    [self.filterSelectorView generateStaticPreviewsForImage:_imageProvider.filterPreviewImage];
    [self.view addSubview:self.filterSelectorView];
    if (![IMGLYDeviceDetector isRunningOn4Inch]) {
        filterSelectorMoveDistance = -84;
    }
}

- (void)configureCameraTopBar {
    self.cameraTopBarView = [[IMGLYCameraTopBarView alloc] initWithYPosition:29];
    self.cameraTopBarView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 55);
    self.cameraTopBarView.delegate = self;
    self.cameraTopBarView.userInteractionEnabled = YES;
    [self.view addSubview:self.cameraTopBarView];
}

- (void)configureCameraBottomBarView {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat bottomBarY = CGRectGetHeight(screenBounds);
    self.cameraBottomBarView = [[IMGLYCameraBottomBarView alloc] initWithYPosition:bottomBarY imageProvider:self.imageProvider];
    [self.view addSubview:self.cameraBottomBarView];
    self.cameraBottomBarView.delegate = self;
}

- (void)configureCameraController {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.cameraController = [[IMGLYCameraController alloc] initWithRect:screenBounds];
    [self.view addSubview:self.cameraController.view];
}

// Add a single tap gesture to focus on the point tapped, then lock focus
- (void)configureGestureRecognizers {
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(tapToAutoFocus:)];
    singleTapGestureRecognizer.delegate = self;
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.cameraController addGestureRecogizerToStreamPreview:singleTapGestureRecognizer];
    
    // Add a double tap gesture to reset the focus mode to continuous auto focus
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(tapToContinuouslyAutoFocus:)];
    doubleTapGestureRecognizer.delegate = self;
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [self.cameraController addGestureRecogizerToStreamPreview:doubleTapGestureRecognizer];
}

- (void)configureShutterView {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGRect layerRect = mainScreen.bounds;
    _shutterView = [[IMGLYShutterView alloc] initWithFrame:layerRect];
    [self.view addSubview:_shutterView];
}

#pragma mark - notification handling
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

}

- (void)addOrientationNotification {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}

#pragma mark - focus handling
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer {
    [self.cameraController onSingleTapFromGestureRecognizer:gestureRecognizer
                                    forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tapToContinuouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer {
    [self.cameraController onDoubleTapFromGestureRecognizer:gestureRecognizer
                                    forInterfaceOrientation:self.interfaceOrientation];
}

#pragma mark - button tap handling
- (UIImage *)cropImage:(UIImage *)image  width:(CGFloat)width height:(CGFloat)height {
    CGRect bounds = CGRectMake(0,
                               0,
                               width,
                               height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


- (void)takePhoto {
    [self preparePhotoTaking];
    [self.cameraController pauseCameraCapture];
    [self.cameraController takePhotoWithCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (error) {
            DLog(@"%@", error.description);
        }
        else {
            
            if (processedImage.size.width == 720 && processedImage.size.height == 1280) { // to support the
                processedImage = [self cropImage:processedImage width:900 height:900];
                 [processedImage imgly_rotateImageToMatchOrientation];
                IMGLYOrientationOperation *operation = [[IMGLYOrientationOperation alloc] init ];
                [operation rotateRight];
                processedImage = [operation processImage:processedImage];
            }
            else if (processedImage.size.width == 1280 && processedImage.size.height == 720) { // to support the
                processedImage = [self cropImage:processedImage width:900 height:900];
            }

            [self finishPhotoTakingWithImage:processedImage];
        }
    }];
}

- (void)preparePhotoTaking {
    [self.cameraBottomBarView disableAllButtons];
    [self.shutterView closeShutter];

    NSInteger timeUntilOpen = 300;
    
    if (![IMGLYDeviceDetector isRunningOn4Inch] && ![IMGLYDeviceDetector isRunningOn4S]) {
        timeUntilOpen = 500;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeUntilOpen * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self.shutterView openShutter];
    });
}

- (void)finishPhotoTakingWithImage:(UIImage *)image {
    [self shutdownCamera];
    [self.cameraBottomBarView enableAllButtons];

    if (![IMGLYDeviceDetector isRunningOn4Inch] && ![IMGLYDeviceDetector isRunningOn4S])
        [SVProgressHUD dismiss];

    [self completeWithResult:IMGLYCameraViewControllerResultDone
                       image:image
                  filterType:self.cameraController.filterType];
}

- (void)selectFromCameraRoll {
    [self openImageFromCameraAndProcessIt];
}

- (void)toggleFilterSelector {
    if (self.cameraBottomBarView.backgroundAlpha == 1.0f)
        [self showFilterSelector];
    else if (self.cameraBottomBarView.backgroundAlpha < 1.0f)
        [self hideFilterSelector];
}

- (void)completeWithResult:(IMGLYCameraViewControllerResult)result
                     image:(UIImage *)image
                filterType:(IMGLYFilterType)filterType {

    if (self.completionHandler)
        self.completionHandler(result, image, filterType);
}

#pragma mark - filterselctor handling
- (void)showFilterSelector {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect viewBounds = self.view.bounds;
        self.filterSelectorView.alpha = 1.0f;
        CGFloat filterSelectorViewOriginY = viewBounds.size.height + filterSelectorMoveDistance;
        self.filterSelectorView.frame = CGRectMake(0.0f,
                                                   filterSelectorViewOriginY,
                                                   self.filterSelectorView.frame.size.width,
                                                   self.filterSelectorView.frame.size.height);
        CGRect bottomFrame = self.cameraBottomBarView.frame;
        bottomFrame.origin.y += filterSelectorMoveDistance;
        self.cameraBottomBarView.frame = bottomFrame;
        [self.cameraBottomBarView setAlphaForAllViews:0.7f];
        [self.cameraTopBarView relayoutForFilterSelectorStatus:!self.isFilterSelectorDown];
    } completion:^(BOOL finished) {
        [self.cameraBottomBarView setArrowDirectionDown];
        self.isFilterSelectorDown = NO;
    }];
}

- (void)hideFilterSelector {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect viewBounds = self.view.bounds;
        self.filterSelectorView.frame = CGRectMake(0.0f,
                                                   viewBounds.size.height,
                                                   self.filterSelectorView.frame.size.width,
                                                   self.filterSelectorView.frame.size.height);
        CGRect bottomFrame = self.cameraBottomBarView.frame;
        bottomFrame.origin.y -= filterSelectorMoveDistance;
        self.cameraBottomBarView.frame = bottomFrame;
        [self.cameraBottomBarView setAlphaForAllViews:1.0f];
        [self.cameraTopBarView relayoutForFilterSelectorStatus:!self.isFilterSelectorDown];
    } completion:^(BOOL finished) {
        [self.cameraBottomBarView setArrowDirectionUp];
        self.isFilterSelectorDown = YES;
    }];
}

- (void)filterSelectorView:(IMGLYFilterSelectorView *)filterSelectorView
       didSelectFilterType:(IMGLYFilterType)filterType {
    [self.cameraController selectFilterType:filterType];
}

#pragma mark - image picker handling 
- (void)openImageFromCameraAndProcessIt {
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.delegate = self;
    [self.cameraController stopCameraCapture];
    [self presentViewController:pickerLibrary animated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.cameraController startCameraCapture];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {

    [self dismissViewControllerAnimated:NO completion:NULL];
    [self finishPhotoTakingWithImage:image];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutShutterView];
}

- (void)layoutShutterView {
    [self.shutterView setFrame:self.view.frame];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    [UIView animateWithDuration:0.2 animations:^{
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                [self.cameraTopBarView rotateForLandscapeLeftOrientation:[self isFilterSelectorDown]];
                [self.cameraBottomBarView rotateForLandscapeLeftOrientation];
                [self.filterSelectorView rotateLanscapeLeftMode];
                break;
            case UIDeviceOrientationLandscapeRight:
                [self.cameraTopBarView rotateForLandscapeRightOrientation:[self isFilterSelectorDown]];
                [self.cameraBottomBarView rotateForLandscapeRightOrientation];
                [self.filterSelectorView rotateLanscapeRightMode];
                break;
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
                [self.cameraTopBarView rotateForPortraitOrientation:[self isFilterSelectorDown]];
                [self.cameraBottomBarView rotateForPortraitOrientation];
                [self.filterSelectorView rotatePortraitOrientation];
                break;
            case UIDeviceOrientationFaceDown:
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationUnknown:
                break;
        }
    }];
}

#pragma mark - image preview handling

- (void)cameraTopBarView:(IMGLYCameraTopBarView *)cameraTopBarView didSelectCameraFlashMode:(IMGLYCameraFlashMode)cameraFlashMode {
    [self.cameraController setCameraFlashMode:cameraFlashMode];
}

- (void)cameraTopBarViewDidToggleCameraPosition:(IMGLYCameraTopBarView *)cameraTopBarView {
    [self.cameraController removeCameraObservers];
    [self.cameraController removeNotifications];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.cameraController setPreviewAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.cameraController flipCamera];
        [self.cameraController hideIndicator];
        
        if([self.cameraController cameraSupportsFlash]) {
            [self.cameraTopBarView showFlashButton];
        }
        else {
            [self.cameraTopBarView hideFlashButton];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.cameraController setPreviewAlpha:1.0];
        }];
    }];

}

#pragma mark - accept / camera mode switching

-(void)shutdownCamera {
    [self.cameraController hideStreamPreview];
    [self.cameraController removeCameraObservers];
    [self.cameraController removeNotifications];
}

-(void)restartCamera {
    [self hideStatusBar];
    [self.cameraController resumeCameraCapture];
    [self.cameraController showStreamPreview];
    [self.cameraController addCameraObservers];
    [self.cameraController addNotifications];
    [self.filterSelectorView setPreviewImagesToDefault];
    sleep(1); // avoid waitin fence error on ios 5
    [self.cameraController startCameraCapture];
    // we need to delay this due synconisation issues with OpenGL
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [self.cameraController selectFilterType:IMGLYFilterTypeNone];
    });
}

#pragma mark - unload

- (void)viewDidUnload {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
}

#pragma mark - system rotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - status bar hiding
- (void)hideStatusBar {
    //viewDidload
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


