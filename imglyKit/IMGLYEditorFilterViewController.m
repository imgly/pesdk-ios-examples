//
// IMGLYEditorFilterViewController
// imglyKit
// 
// Created by Carsten Przyluczky on 24.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorFilterViewController.h"

#import "IMGLYFilterOperation.h"
#import "IMGLYFilterSelectorView.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYProcessingJob.h"
#import "IMGLYEditorImageProvider.h"
#import "UINavigationController+IMGLYAdditions.h"
#import "IMGLYAvailableFilterListProvider.h"

extern CGFloat const kIMGLYImageOffset;
static CGFloat const kIMGLYPreviewImageSize = 50.0;
CGFloat const kIMGLYPreviewImageDistance;
static CGFloat const kIMGLYPreviewImageTextHeight = 22.0f;
extern CGFloat const kIMGLYExtraSpaceForScrollBar;
extern CGFloat const kEditorMenuViewHeight;

@interface IMGLYEditorFilterViewController() <IMGLYFilterSelectorViewDelegate>

@property (nonatomic, strong) IMGLYFilterSelectorView *filterSelectorView;
@property (nonatomic, assign) IMGLYFilterType currentFilterType;
@property (nonatomic, strong) NSArray *availableFilterList;

@end

@implementation IMGLYEditorFilterViewController

- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super init];
    if (self == nil)
        return nil;

    return self;
}

- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    return self;
}

#pragma mark - GUI configuration
- (void)viewDidAppear:(BOOL)animated {
    if(_availableFilterList == nil) {
        _availableFilterList = [self getAvailableFilterListFromParent];
    }
    [self commonInit];
    [self.filterSelectorView generatePreviewsForImage:self.inputImage];
}

- (void)commonInit {
    self.title = @"Filters";
    self.currentFilterType = IMGLYFilterTypeNone;
    [self configureFilterSelectorView];
}

- (void)configureFilterSelectorView {
    CGRect viewBounds = self.view.bounds;
    CGFloat selectorViewHeight = 95;
    CGRect selectorViewFrame = CGRectMake(0.0f, self.imagePreview.frame.size.height - kEditorMenuViewHeight, viewBounds.size.width, selectorViewHeight);
    _filterSelectorView = [[IMGLYFilterSelectorView alloc] initWithFrame:selectorViewFrame
                                                        previewImageSize:kIMGLYPreviewImageSize
                                                     editorImageProvider:self.imageProvider availableFilterList:_availableFilterList];
    _filterSelectorView.delegate = self;
    [_filterSelectorView hideBackground];
    [self.view addSubview:_filterSelectorView];
}

#pragma mark - filterSelector delegation
- (void)filterSelectorView:(IMGLYFilterSelectorView *)filterSelectorView
       didSelectFilterType:(IMGLYFilterType)filterType {
    self.currentFilterType = filterType;
    [self updateImagePreview];
}

- (void)setInputImage:(UIImage *)inputImage {
    [super setInputImage:inputImage];
    [self updateImagePreview];
}

#pragma mark - layout
- (void)layoutFilterSelector {
    CGFloat selectorViewHeight = kIMGLYPreviewImageSize + kIMGLYPreviewImageTextHeight + kIMGLYExtraSpaceForScrollBar;
    CGRect selectorViewFrame = CGRectMake(0.0f,  self.view.bounds.size.height - kEditorMenuViewHeight, self.view.bounds.size.width, selectorViewHeight);
    self.filterSelectorView.frame = selectorViewFrame;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutFilterSelector];
}

#pragma mark - filter processing
- (IMGLYProcessingJob *)prosessingJob {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYFilterOperation *operation = [[IMGLYFilterOperation alloc] init];
    operation.filterType = self.currentFilterType;
    [job addOperation:(IMGLYOperation *)operation];
    return job;
}

- (void)updateImagePreview {
    IMGLYProcessingJob *job = [self prosessingJob];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    self.imagePreview.image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
}

- (void)setCurrentProcessingJob:(IMGLYProcessingJob *)currentProcessingJob {
    _currentProcessingJob = [currentProcessingJob copy]; // make a copy so if user presses back all changes are discarded
    // if that job contrains a filter operation lets set that filter type
    for (id <IMGLYOperation> operation in _currentProcessingJob.operations) {
        if ([operation class] == [IMGLYFilterOperation class]) {
            self.currentFilterType = ((IMGLYFilterOperation*)operation).filterType;
        }
    }
    [self updateImagePreview];
}

#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
        IMGLYProcessingJob *job = [self prosessingJob];
        self.completionHandler(IMGLYEditorViewControllerResultDone,self.imagePreview.image, job);
    }
}

- (NSArray *)getAvailableFilterListFromParent {
    NSArray *list = nil;
    // get the index of the visible VC on the stack
    int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    // get a reference to the previous VC
    id prevVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];

    if(prevVC != nil) {
        if([prevVC conformsToProtocol:@protocol(IMGLYAvailableFilterListProvider)]) {
            id<IMGLYAvailableFilterListProvider> listProvider = (id<IMGLYAvailableFilterListProvider>)prevVC;
            list = [listProvider provideAvailableFilterList];
        }
    }
    return list;
}


@end
