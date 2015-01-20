//
//  IMGLYEditorFocusViewController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 05.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorFocusViewController.h"

#import "IMGLYEditorBoxGradientView.h"
#import "IMGLYEditorCircleGradientView.h"
#import "IMGLYEditorFocusMenu.h"
#import "IMGLYGaussOperation.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYProcessingJob.h"
#import "SVProgressHUD.h"
#import "UINavigationController+IMGLYAdditions.h"

static const CGFloat kMenuViewHeight = 95.0;

@interface IMGLYEditorFocusViewController() <IMGLYEditorFocusMenuDelegate, IMGLYEditorGradientViewDelegate>

@property (nonatomic, strong) IMGLYEditorBoxGradientView *boxGradientView;
@property (nonatomic, strong) IMGLYEditorCircleGradientView *circleGradientView;
@property (nonatomic, strong) IMGLYEditorFocusMenu *menu;
@property (nonatomic, assign) IMGLYTiltShiftMode tiltShiftMode;
@property (nonatomic, strong) UIImage *blurredImage;
@property (nonatomic, strong) NSOperationQueue *queue;


@end

@implementation IMGLYEditorFocusViewController

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

- (void) commonInit {
    self.title = @"Focus";
    _queue = [[NSOperationQueue alloc] init];
    [self disableZoomOnTap];
    [self configureCircleGradientView];
    [self configureBoxGradientView];
    [self configureMenu];
    self.tiltShiftMode = IMGLYTiltShiftModeBox;
    [self.menu setTiltShiftMode:IMGLYTiltShiftModeBox];
}

- (void) configureMenu {
    _menu = [[IMGLYEditorFocusMenu alloc] initWithFrame:CGRectZero imageProvider:self.imageProvider];
    _menu.menuDelegate = self;
    [self.view addSubview:_menu];
}

- (void) configureBoxGradientView {
    _boxGradientView = [[IMGLYEditorBoxGradientView alloc] initWithFrame:CGRectZero imageProvider:self.imageProvider];
    _boxGradientView.hidden = NO;
    _boxGradientView.gradientViewDelegate = self;
    [self.view addSubview:_boxGradientView];
}

- (void) configureCircleGradientView {
    _circleGradientView = [[IMGLYEditorCircleGradientView alloc] initWithFrame:CGRectZero imageProvider:self.imageProvider];
    _circleGradientView.hidden = YES;
    _circleGradientView.gradientViewDelegate = self;
    [self.view addSubview:_circleGradientView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD showWithStatus:@"Preprocessing"];

    __weak IMGLYEditorFocusViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        IMGLYEditorFocusViewController *strongSelf = weakSelf;
        [strongSelf createBlurredImage];
    }];

    __weak NSBlockOperation *weakOperation = operation;
    operation.completionBlock = ^{
        NSBlockOperation *strongOperation = weakOperation;
        if([strongOperation isCancelled]) {
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            IMGLYEditorFocusViewController *strongSelf = weakSelf;
            [strongSelf updatePreviewImageAndDismissProgress];
        }];
    };

    [self.queue addOperation:operation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.queue cancelAllOperations];
    if([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)updatePreviewImageAndDismissProgress {
    [self updatePreviewImage];
    [SVProgressHUD dismiss];
}

- (void)setInputImage:(UIImage *)inputImage {
    [super setInputImage:inputImage];
    [self layoutBoxGradientView];
    [self layoutCircleGradientView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutBoxGradientView];
    [self layoutCircleGradientView];
    [self layoutMenu];
}

- (void)layoutBoxGradientView {
    CGSize size = [self scaledImageSize];
    CGFloat xOffset = (self.view.frame.size.width - size.width) / 2.0;
    CGFloat yOffset = (self.view.frame.size.height - size.height - self.editMenuHeight) / 2.0;
    self.boxGradientView.frame = CGRectMake(xOffset,
                                         yOffset,
                                         size.width,
                                         size.height);
}

- (void)layoutCircleGradientView {
    CGSize size = [self scaledImageSize];
    CGFloat xOffset = (self.view.frame.size.width - size.width) / 2.0;
    CGFloat yOffset = (self.view.frame.size.height - size.height - self.editMenuHeight) / 2.0;
    self.circleGradientView.frame = CGRectMake(xOffset,
                                            yOffset,
                                            size.width,
                                            size.height);
}

- (void)layoutMenu {
    self.menu.frame = CGRectMake(0,
                                self.view.frame.size.height - kMenuViewHeight ,
                                self.view.frame.size.width,
                                kMenuViewHeight);
}

#pragma mark - processing
- (void)createBlurredImage {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYGaussOperation *operation = [[IMGLYGaussOperation alloc] init];
    
    [job addOperation:(IMGLYOperation *)operation];
    
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.blurredImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

- (IMGLYProcessingJob *)processingJob {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYTiltShiftOperation *operation = [[IMGLYTiltShiftOperation alloc] init];
    operation.blurredImage = self.blurredImage;
    if (self.tiltShiftMode == IMGLYTiltShiftModeBox) {
        operation.controlPoint1 = [self normalizedPoint:self.boxGradientView.controllPoint1];
        operation.controlPoint2 = [self normalizedPoint:self.boxGradientView.controllPoint2];
    }
    else {
        operation.controlPoint1 = [self normalizedPoint:self.circleGradientView.controllPoint1];
        operation.controlPoint2 = [self normalizedPoint:self.circleGradientView.controllPoint2];
    }
    
    operation.tiltShiftMode = self.tiltShiftMode;
    
    if (self.imagePreview.image.size.height > self.imagePreview.image.size.width) {
        operation.scaleVector = CGPointMake(self.imagePreview.image.size.width / self.imagePreview.image.size.height, 1.0);
    }
    else {
        operation.scaleVector = CGPointMake(1.0, self.imagePreview.image.size.height / self.imagePreview.image.size.width);
    }
    
    [job addOperation:(IMGLYOperation *)operation];
    return job;
}

- (void) updatePreviewImage {
    IMGLYProcessingJob *job = [self processingJob];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.imagePreview.image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

#pragma mark - menu handling
- (void)circleModeTouchedUpInside {
    [self.menu setTiltShiftMode:IMGLYTiltShiftModeCircle];
    self.boxGradientView.hidden = YES;
    self.circleGradientView.hidden = NO;
    self.tiltShiftMode = IMGLYTiltShiftModeCircle;
    self.circleGradientView.controllPoint1 = CGPointMake(self.boxGradientView.controllPoint1.x, self.boxGradientView.controllPoint1.y);
    self.circleGradientView.controllPoint2 = CGPointMake(self.boxGradientView.controllPoint2.x, self.boxGradientView.controllPoint2.y);
    [self updatePreviewImage];
}

- (void)boxModeTouchedUpInside {
    [self.menu setTiltShiftMode:IMGLYTiltShiftModeBox];
    self.boxGradientView.hidden = NO;
    self.circleGradientView.hidden = YES;
    self.tiltShiftMode = IMGLYTiltShiftModeBox;
    self.boxGradientView.controllPoint1 = CGPointMake(self.circleGradientView.controllPoint1.x, self.circleGradientView.controllPoint1.y);
    self.boxGradientView.controllPoint2 = CGPointMake(self.circleGradientView.controllPoint2.x, self.circleGradientView.controllPoint2.y);
    [self updatePreviewImage];
}

#pragma mark - tool
- (CGPoint)normalizedPoint:(CGPoint)point {
    CGFloat boundWidth = self.rightPreviewBound - self.leftPreviewBound;
    CGFloat boundHeight = self.bottomPreviewBound - self.topPreviewBound;

    CGFloat x = point.x  / boundWidth;
    CGFloat y = point.y / boundHeight;
    
    return CGPointMake(x,y);
}

#pragma mark - gradient view communication
-(void) controlPointChanged {

}

- (void)userInteractionStarted {
    self.imagePreview.image = self.inputImage;
}
- (void)userInteractionEnded {
    [self updatePreviewImage];
}

#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
	    IMGLYProcessingJob *job = [self processingJob];
        IMGLYTiltShiftOperation *operation = [job.operations objectAtIndex:0];
        operation.blurredImage = nil;    // this forces a recalculation of the blurred image
        self.completionHandler(IMGLYEditorViewControllerResultDone,self.imagePreview.image, job);
    }
}
@end
