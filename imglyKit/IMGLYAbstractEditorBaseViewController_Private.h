//
//  IMGLYAbstractEditorBaseViewController_Private.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYAbstractEditorBaseViewController.h"

@class IMGLYProcessingJob;

@interface IMGLYAbstractEditorBaseViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imagePreview;
@property (nonatomic, strong) UIScrollView *previewScrollView;
@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, strong) UIImageView *fullScreenImageView;
@property (nonatomic, assign) BOOL previewZoomed;
@property (nonatomic, assign) BOOL previewZoomEnabled;
@property (nonatomic, assign) CGFloat editMenuHeight;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) IMGLYProcessingJob *job;
@property (nonatomic, assign) CGFloat leftPreviewBound;
@property (nonatomic, assign) CGFloat rightPreviewBound;
@property (nonatomic, assign) CGFloat topPreviewBound;
@property (nonatomic, assign) CGFloat bottomPreviewBound;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

- (void)disableZoomOnTap;
- (CGSize)scaledImageSize;
- (void)recalculateImagePreviewBounds;
- (void)showDoneButton;
- (void)hideDoneButton;

@end
