//
// IMGLYEditorEnhancementViewController.m
// imglyKit
// 
// Created by Carsten Przyluczky on 22.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorEnhancementViewController.h"

#import "SVProgressHUD.h"
#import "IMGLYEnhancementOperation.h"
#import "IMGLYProcessingJob.h"
#import "IMGLYPhotoProcessor.h"
#import "UINavigationController+IMGLYAdditions.h"

@interface IMGLYEditorEnhancementViewController()

@property (nonatomic, strong) UISwitch *toggle;
@property (nonatomic, strong) UIImage *enhancedImage;
@property (nonatomic, strong) NSOperationQueue *queue;

@end


@implementation IMGLYEditorEnhancementViewController

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
    self.title = @"Magic";
    _queue = [[NSOperationQueue alloc] init];
    [self configureSwitch];
}

- (void)configureSwitch {
    _toggle = [[UISwitch alloc] init];
    _toggle.on = YES;
    [_toggle addTarget:self action:@selector(togglePreview:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_toggle];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD showWithStatus:@"Preprocessing"];

    __weak IMGLYEditorEnhancementViewController *weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        IMGLYEditorEnhancementViewController *strongSelf = weakSelf;
        [strongSelf createEnhancedImage];
    }];

    __weak NSBlockOperation *weakOperation = operation;
    operation.completionBlock = ^{
        NSBlockOperation *strongOperation = weakOperation;
        if ([strongOperation isCancelled]) {
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            IMGLYEditorEnhancementViewController *strongSelf = weakSelf;
            [strongSelf updatePreviewImageAndDismissProgress];
        }];
    };

    [self.queue addOperation:operation];
}

- (void)updatePreviewImageAndDismissProgress {
    [self updatePreviewImage];
    [SVProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.queue cancelAllOperations];
    if([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - processing
- (IMGLYProcessingJob *)processingJob {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYEnhancementOperation *enhancementOperation = [[IMGLYEnhancementOperation alloc] init];

    [job addOperation:(IMGLYOperation *)enhancementOperation];
    return job;
}


- (void)createEnhancedImage {
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:[self processingJob] ];
    self.enhancedImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutSwitch];
}

- (void)layoutSwitch {
    // we put the slider y to the half of the menu - the half of the slider height.
    // that way its centred y-wise
    self.toggle.frame = CGRectMake(120.0,
            self.view.frame.size.height - self.editMenuHeight / 2.0 - 22.0 / 2.0,
            self.view.frame.size.width - 2.0 * 100.0,
            10.0);

}

#pragma mark - inputImage
- (void) updatePreviewImage {
    if(self.toggle.on) {
        self.imagePreview.image = self.enhancedImage;
    }
    else {
        self.imagePreview.image = self.inputImage;
    }
}

#pragma mark - button handler
- (void)togglePreview:(id)sender {
    [self updatePreviewImage];
}

- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
        if (self.toggle.on) {
            self.completionHandler(IMGLYEditorViewControllerResultDone,self.imagePreview.image, [self processingJob]);
        }
        else {
            self.completionHandler(IMGLYEditorViewControllerResultDone,nil , nil);
        }
    }
}
@end
