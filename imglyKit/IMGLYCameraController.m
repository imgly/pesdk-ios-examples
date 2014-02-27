//
//  IMGLYCameraController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 07.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYCameraController.h"

#import "IMGLYCameraViewController.h"
#import "IMGLYDefines.h"
#import "IMGLYDeviceDetector.h"
#import "IMGLYFilter.h"
#import "IMGLYLiveStreamFilterManager.h"

#import <NEGPUImage/GPUImage.h>
#import <QuartzCore/QuartzCore.h>

static CGFloat const kIMGLYIndicatorSize = 50;
static CGFloat const kIMGLYStreamPreviewYTranslation = -26;

@interface IMGLYCameraController ()

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *doNothingFilter;
@property (nonatomic, strong) GPUImageView *streamPreviewView;
@property (nonatomic, strong) CALayer *indicatorLayer;
@property (nonatomic, assign) BOOL focusObserverAdded;
@property (nonatomic, assign) BOOL showIndicator;
@property (nonatomic, assign) void *AVCamFocusModeObserverContext;
@property (nonatomic, assign) void *AVCamExposureModeObserverContext;
@property (nonatomic, strong) IMGLYLiveStreamFilterManager *liveStreamFilterManager;
@property (nonatomic, assign) IMGLYFilterType filterTypeBeforeResign;
@property (nonatomic, assign) BOOL isSleeping;

@end

#pragma mark -

@implementation IMGLYCameraController

#pragma mark Initialization

- (instancetype)initWithRect:(CGRect)rect {
    self = [super init];
    if (self == nil)
        return nil;
    
    _rect = rect;
    
    _view = [[UIView alloc] initWithFrame:rect];
    _view.autoresizesSubviews = YES;
    _view.userInteractionEnabled = YES;

    [self commonInit];

    return self;
}

- (void)commonInit {
    _isSleeping = NO;
    _focusObserverAdded = NO;
    _showIndicator = YES;
    _cameraFlashMode = IMGLYCameraFlashModeAuto;
    _cameraPosition = IMGLYCameraPositionBack;

    [self createStreamPreviewView];
    [self configureCamera];
    [self configureIndicatorLayer];
}

- (void)createStreamPreviewView {
    CGRect frame = CGRectMake(0, 0, self.rect.size.width, self.rect.size.height);
    _streamPreviewView = [[GPUImageView alloc] initWithFrame:frame];
    _streamPreviewView.userInteractionEnabled = YES;
    [self.view addSubview:_streamPreviewView];
}

- (void)configureCamera {
    [_stillCamera stopCameraCapture];

    _liveStreamFilterManager = [[IMGLYLiveStreamFilterManager alloc] init];
    _doNothingFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];

    if (_cameraPosition == IMGLYCameraPositionBack)
        [self setupCameraInBackPosition];
    else
        [self setupCameraInFrontPosition];

    [self connectFilterAndGUI];
    [_stillCamera startCameraCapture];
    [self addNotifications];
    [self addCameraObservers];
}

- (void)setupCameraInBackPosition {
    if ([IMGLYDeviceDetector isRunningOn4Inch]) {
        _streamPreviewView.transform = CGAffineTransformMakeScale(1, 1.12);
        _streamPreviewView.transform = CGAffineTransformTranslate(self.streamPreviewView.transform, 0, -41);
    }
    else if ([IMGLYDeviceDetector isRunningOn4S]) {
        _streamPreviewView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _streamPreviewView.transform = CGAffineTransformTranslate(self.streamPreviewView.transform,
                                                                  0,
                                                                  30);
    }
    else {
        _streamPreviewView.transform = CGAffineTransformMakeScale(1, 1);
        _streamPreviewView.transform = CGAffineTransformTranslate(self.streamPreviewView.transform,
                                                                  0,
                                                                  kIMGLYStreamPreviewYTranslation);
    }
    
    if ([IMGLYDeviceDetector isRunningOn3GS]) {
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh
                                                           cameraPosition:AVCaptureDevicePositionBack];
    }
    else if ([IMGLYDeviceDetector isRunningOn4S]) {
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetiFrame1280x720
                                                           cameraPosition:AVCaptureDevicePositionBack];
    }
    else {
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto
                                                           cameraPosition:AVCaptureDevicePositionBack];
    }

    GPUImageCropFilter *filter = (GPUImageCropFilter *)_doNothingFilter;
    filter.cropRegion = CGRectMake(0, 0, 1, 1);
}

- (void)setupCameraInFrontPosition {
    _streamPreviewView.transform = CGAffineTransformMakeScale(-1, 1); // this flips horizontaly
    _streamPreviewView.transform = CGAffineTransformTranslate(self.streamPreviewView.transform, 0, -25);
    _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                       cameraPosition:AVCaptureDevicePositionFront];
    [(GPUImageCropFilter *)_doNothingFilter setCropRegion:CGRectMake(0, 0, 1, 1)];
}

- (void)connectFilterAndGUI {
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_stillCamera addTarget:_liveStreamFilterManager.currentFilter];
    [_liveStreamFilterManager.currentFilter addTarget:_streamPreviewView];
    [_doNothingFilter addTarget:_streamPreviewView];
}

- (void)configureIndicatorLayer {
    _indicatorLayer = [CALayer layer];
    _indicatorLayer.borderColor = [[UIColor whiteColor] CGColor];
    _indicatorLayer.borderWidth = 1;
    _indicatorLayer.frame = CGRectMake(self.view.bounds.size.width / 2 - kIMGLYIndicatorSize / 2,
                                       self.view.bounds.size.height / 2 - kIMGLYIndicatorSize / 2,
                                       kIMGLYIndicatorSize,
                                       kIMGLYIndicatorSize);
    _indicatorLayer.hidden = YES;
    [self.view.layer addSublayer:_indicatorLayer];
}

#pragma mark Gestures

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)onSingleTapFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                 forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    self.showIndicator = YES;
    CGPoint tapPoint = [gestureRecognizer locationInView:self.view];
    
    // since we check gestures on the non rotating view controler, we must rotate the tap our selfs
    if(interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        tapPoint.y = self.view.layer.bounds.size.height - tapPoint.y;
        float temp = tapPoint.x;
        tapPoint.x = tapPoint.y;
        tapPoint.y = temp;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        tapPoint.x = self.view.layer.bounds.size.width - tapPoint.x;
        float temp = tapPoint.x;
        tapPoint.x = tapPoint.y;
        tapPoint.y = temp;
    }
    
    self.indicatorLayer.frame = CGRectMake(tapPoint.x - kIMGLYIndicatorSize /2.0,
                                           tapPoint.y - kIMGLYIndicatorSize /2.0,
                                           kIMGLYIndicatorSize,
                                           kIMGLYIndicatorSize);
    
    [self.stillCamera setFocus:tapPoint : self.streamPreviewView.frame.size];
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)onDoubleTapFromGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                 forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    self.showIndicator = NO;
    [self.stillCamera setToAutoFocusMode];
}

- (void)addGestureRecogizerToStreamPreview:(UIGestureRecognizer *)gestureRecognizer {
    [self.view addGestureRecognizer:gestureRecognizer];
}

#pragma mark Notifications

- (void)addNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(captureSessionRuntimeError:)
                               name:AVCaptureSessionRuntimeErrorNotification
                             object:_stillCamera.captureSession];

    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];

    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (context == _AVCamFocusModeObserverContext && _focusObserverAdded) {
        if ((AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue] == AVCaptureFocusModeLocked)
            _indicatorLayer.hidden = YES;
        else {
            if(_showIndicator)
                _indicatorLayer.hidden = NO;
        }

        return;
 	}

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)addCameraObservers {
    if ([_stillCamera isAutoFocusSupported] && !_focusObserverAdded) {
        [self addObserver:self
               forKeyPath:@"stillCamera.inputCamera.focusMode"
                  options:NSKeyValueObservingOptionNew
                  context:_AVCamFocusModeObserverContext];

        _focusObserverAdded = YES;
    }
}

- (void)removeCameraObservers {
    if ([_stillCamera isAutoFocusSupported] && _focusObserverAdded) {
        [self removeObserver:self forKeyPath:@"stillCamera.inputCamera.focusMode"];
        _focusObserverAdded = NO;
    }
}

- (void)captureSessionRuntimeError:(NSNotification *)notification {
    __unused NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    DLog(@"Capture session runtime error: %@", [error localizedDescription]);
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.stillCamera pauseCameraCapture];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self.stillCamera resumeCameraCapture];
}

#pragma mark Stream Control

- (void)startCameraCapture {
    [self.stillCamera startCameraCapture];
}

- (void)stopCameraCapture {
    [self.stillCamera stopCameraCapture];
}

- (void)pauseCameraCapture {
    [self.stillCamera pauseCameraCapture];
}

- (void)resumeCameraCapture {
    [self.stillCamera resumeCameraCapture];
}

- (void)hideStreamPreview {
    self.streamPreviewView.hidden = YES;
}

- (void)showStreamPreview {
    self.streamPreviewView.hidden = NO;
}

#pragma mark Taking a Photo

- (void)takePhotoWithCompletionHandler:(void (^)(UIImage *processedImage, NSError *error))completionHandler  {
    [self setupFlash];
    [self.stillCamera capturePhotoAsImageWithCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if (completionHandler)
            completionHandler(processedImage, error);
    }];
}

- (void)setupFlash {
    if (!self.stillCamera.inputCamera.isFlashAvailable)
        return;

    [self.stillCamera.inputCamera lockForConfiguration:NULL];
    switch (self.cameraFlashMode) {
        case IMGLYCameraFlashModeAuto:
            self.stillCamera.inputCamera.flashMode = AVCaptureFlashModeAuto;
            break;
        case IMGLYCameraFlashModeOff:
            self.stillCamera.inputCamera.flashMode = AVCaptureFlashModeOff;
            break;
        case IMGLYCameraFlashModeOn:
            self.stillCamera.inputCamera.flashMode = AVCaptureFlashModeOn;
            break;
        case IMGLYCameraFlashModeUnkown:
            break;
    }
    [self.stillCamera.inputCamera unlockForConfiguration];
}

#pragma mark Configuration Interface

- (IMGLYFilterType)filterType {
    return self.liveStreamFilterManager.filterType;
}

- (void)selectFilterType:(IMGLYFilterType)filterType {
    [self.liveStreamFilterManager setFilterWithType:filterType];
    [[self.liveStreamFilterManager currentFilter] addTarget:self.streamPreviewView];
    [self.stillCamera removeAllTargets];
    [self.stillCamera addTarget:[self.liveStreamFilterManager currentFilter]];
}

- (void)flipCamera {
    switch (self.cameraPosition) {
        case IMGLYCameraPositionBack:
            self.cameraPosition = IMGLYCameraPositionFront;
            break;
        case IMGLYCameraPositionFront:
            self.cameraPosition = IMGLYCameraPositionBack;
            break;
        case IMGLYCameraPositionUnkown:
            break;
    }

    [self configureCamera];
}

- (BOOL)cameraSupportsFlash {
    return self.stillCamera.inputCamera.flashAvailable;
}

- (void)setPreviewAlpha:(CGFloat)alpha {
    self.streamPreviewView.alpha = alpha;
}

- (void)hideIndicator {
    self.indicatorLayer.hidden = YES;
}

@end
