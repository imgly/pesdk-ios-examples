//
//  IMGLYEditorOrientationViewController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 20.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorOrientationViewController.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYOrientationOperation.h"
#import "IMGLYProcessingJob.h"
#import "IMGLYEditorOrientationMenu.h"
#import "UINavigationController+IMGLYAdditions.h"

static const CGFloat kMenuViewHeight = 95.0;

@interface IMGLYEditorOrientationViewController() <IMGLYEditorOrientationMenuDelegate>

@property (nonatomic, strong) IMGLYEditorOrientationMenu *menu;

// for this dialog we store the operation on a member level, so we can use
// the helper methods it provides
@property (nonatomic, strong) IMGLYOrientationOperation *operation;

@end

@implementation IMGLYEditorOrientationViewController

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
    self.title = @"Orientation";
    [self configureMenu];
    [self configureOperation];
}

- (void) configureMenu {
    _menu = [[IMGLYEditorOrientationMenu alloc] initWithFrame:CGRectZero imageProvider:self.imageProvider];
    _menu.menuDelegate = self;
    [self.view addSubview:_menu];
}

- (void) configureOperation {
    _operation = [[IMGLYOrientationOperation alloc] init];
}

- (IMGLYProcessingJob *) processingJob {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    [job addOperation:(IMGLYOperation *)self.operation];
    return job;
}

#pragma mark - processign
- (void) updatePreviewImage {
    IMGLYProcessingJob *job = [self processingJob];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.imagePreview.image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

#pragma mark - menu delegation
- (void)rotateLeftTouchedUpInside {
    [self.operation rotateLeft];
    [self updatePreviewImage];
}

- (void)rotateRightTouchedUpInside {
    [self.operation rotateRight];
    [self updatePreviewImage];
}

- (void)flipVerticalTouchedUpInside  {
    [self.operation flipVertical];
    [self updatePreviewImage];
}

- (void)flipHorizontalTouchedUpInside {
    [self.operation flipHorizontal];
    [self updatePreviewImage];
}

#pragma mark - layout 
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutMenu];
}


- (void)layoutMenu {
    self.menu.frame = CGRectMake(0,
                                 self.view.frame.size.height - kMenuViewHeight ,
                                 self.view.frame.size.width,
                                 kMenuViewHeight);
}


#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
	    IMGLYProcessingJob *job = [self processingJob];
        self.completionHandler(IMGLYEditorViewControllerResultDone,self.imagePreview.image, job);
    }
}

@end
