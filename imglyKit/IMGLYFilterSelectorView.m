//
//  IMGLYFilterSelectorView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilterSelectorView.h"

#import "IMGLYDefines.h"
#import "IMGLYDefaultCameraImageProvider.h"
#import "IMGLYEditorImageProvider.h"
#import "IMGLYFilterSelectorButtonMetadata.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYProcessingJob.h"
#import "IMGLYFilterOperation.h"

CGFloat const kIMGLYPreviewImageOffset = 8.0f;
CGFloat const kIMGLYPreviewImageDistance = 10.0f;
static CGFloat const kIMGLYPreviewImageTextHeight = 18.0f;
CGFloat const kIMGLYExtraSpaceForScrollBar = 7.0f;
const CGFloat kActivationDuration = 0.15f;

@interface IMGLYFilterSelectorView ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *gradientView;
@property (readonly, nonatomic) dispatch_queue_t contextQueue;
@property (nonatomic, assign) CGFloat previewImageSize;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> editorImageProvider;
@property (nonatomic, strong) id<IMGLYCameraImageProvider> cameraImageProvider;
@property (nonatomic, strong) NSArray *availableFilterList;
@property (nonatomic, strong) UIButton *lastClickedFilterButton;
@property (nonatomic, strong) UIImageView *tickImageView;

@end

#pragma mark -

@implementation IMGLYFilterSelectorView

#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize {
    self = [super initWithFrame:frame];
    if (self) {
        _previewImageSize = previewImageSize;
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize editorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self) {
        _editorImageProvider = imageProvider;
        _previewImageSize = previewImageSize;
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize editorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider availableFilterList:(NSArray *)list {
    self = [super initWithFrame:frame];
    if (self) {
        _editorImageProvider = imageProvider;
        _previewImageSize = previewImageSize;
        _availableFilterList = list;
        [self commonInit];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize cameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self) {
        _cameraImageProvider = imageProvider;
        _previewImageSize = previewImageSize;
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize cameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider availableFilterList:(NSArray *)list {
    self = [super initWithFrame:frame];
    if (self) {
        _cameraImageProvider = imageProvider;
        _previewImageSize = previewImageSize;
        _availableFilterList = list;
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _lastClickedFilterButton = nil;
    if (_editorImageProvider == nil &&  _cameraImageProvider == nil) {
        _cameraImageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    }
    
    _dictionary = [[NSMutableDictionary alloc] init];
    _contextQueue = dispatch_queue_create("ly.img.filterPreviewQueue", DISPATCH_QUEUE_SERIAL);
    [self addGradientView];
    [self addScrollView];
    if(_availableFilterList != nil) {
        [self buildFilterPreviewList];
    }
    else {
        [self buildFilterPreviewListWithAllFilters];
    }

    [self rearrangeViews];
    [self addTickImageView];
    [self setFirstFilterAsActive];
    self.alpha = 1.0f;
}

- (void)setFirstFilterAsActive {
    UIButton *button = [[_scrollView subviews] objectAtIndex:0];
    [self filterButtonTouchedUpInside:button];
}

- (void)addTickImageView {
    _tickImageView = [[UIImageView alloc] init];
    _tickImageView.contentMode = UIViewContentModeCenter;
    if (_editorImageProvider != nil) {
        _tickImageView.image = [_editorImageProvider filterActiveIcon];
    } else {
        _tickImageView.image = [_cameraImageProvider filterActiveIcon];
    }
    _tickImageView.frame = CGRectMake(0, 0, _previewImageSize, _previewImageSize);
    [_scrollView addSubview:_tickImageView];
}

- (void)addGradientView {
    UIImage *gradientImage = nil;
    if (_editorImageProvider != nil) {
        gradientImage = [_editorImageProvider gradientImage];
    }
    else {
        gradientImage = [_cameraImageProvider gradientImage];
    }
    _gradientView = [[UIImageView alloc] initWithImage:gradientImage];
    _gradientView.frame = CGRectMake(0.0f, 0.0f, gradientImage.size.width, gradientImage.size.height);
    [self addSubview:_gradientView];
}

- (void)addScrollView {
    CGRect scrollViewFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

/*
    This method adds the set of all available fitlers to the available filters list.
    It is called in case the user did not set a list.
 */
- (void)buildFilterPreviewListWithAllFilters {
    _availableFilterList = @[
        @(IMGLYFilterTypeNone),
        @(IMGLYFilterType9EK1),
        @(IMGLYFilterType9EK2),
        @(IMGLYFilterType9EK6),
        @(IMGLYFilterType9EKDynamic),
        @(IMGLYFilterTypeFridge),
        @(IMGLYFilterTypeBreeze),
        @(IMGLYFilterTypeOchrid),
        @(IMGLYFilterTypeChestnut),
        @(IMGLYFilterTypeFront),
        @(IMGLYFilterTypeFixie),
        @(IMGLYFilterTypeX400),
        @(IMGLYFilterTypeBW),
        @(IMGLYFilterTypeBWHard),
        @(IMGLYFilterTypeLenin),
        @(IMGLYFilterTypeQouzi),
        @(IMGLYFilterType669),
        @(IMGLYFilterTypePola),
        @(IMGLYFilterTypeFood),
        @(IMGLYFilterTypeGlam),
        @(IMGLYFilterTypeLord),
        @(IMGLYFilterTypeTejas),
        @(IMGLYFilterTypeEarlyBird),
        @(IMGLYFilterTypeLomo),
        @(IMGLYFilterTypeGobblin),
        @(IMGLYFilterTypeSinCity),
        @(IMGLYFilterTypeSketch),
        @(IMGLYFilterTypeMellow),
        @(IMGLYFilterTypeSunny),
        @(IMGLYFilterTypeA15),
        @(IMGLYFilterTypeSemiRed),
    ];

    [self buildFilterPreviewList];
}

- (void)buildFilterPreviewList {
    for (NSNumber *filterTypeAsNumber in self.availableFilterList) {
        IMGLYFilterType filterType = (IMGLYFilterType)[filterTypeAsNumber integerValue];
        switch (filterType) {
            case IMGLYFilterType9EK1:
                [self addFilterSelectButtonWithFilterName:@"K1" action:IMGLYFilterType9EK1];
                break;
            case IMGLYFilterType9EK2:
                [self addFilterSelectButtonWithFilterName:@"K2" action:IMGLYFilterType9EK2];
                break;
            case IMGLYFilterType9EK6:
                [self addFilterSelectButtonWithFilterName:@"K6" action:IMGLYFilterType9EK6];
                break;
            case IMGLYFilterType9EKDynamic:
                [self addFilterSelectButtonWithFilterName:@"KDynamic" action:IMGLYFilterType9EKDynamic];
                break;
            case IMGLYFilterTypeFridge:
                [self addFilterSelectButtonWithFilterName:@"Fridge" action:IMGLYFilterTypeFridge];
                break;
            case IMGLYFilterTypeBreeze:
                [self addFilterSelectButtonWithFilterName:@"Breeze" action:IMGLYFilterTypeBreeze];
                break;
            case IMGLYFilterTypeOchrid:
                [self addFilterSelectButtonWithFilterName:@"Orchid" action:IMGLYFilterTypeOchrid];
                break;
            case IMGLYFilterTypeChestnut:
                [self addFilterSelectButtonWithFilterName:@"Chest" action:IMGLYFilterTypeChestnut];
                break;
            case IMGLYFilterTypeFront:
                [self addFilterSelectButtonWithFilterName:@"Front" action:IMGLYFilterTypeFront];
                break;
            case IMGLYFilterTypeFixie:
                [self addFilterSelectButtonWithFilterName:@"Fixie" action:IMGLYFilterTypeFixie];
                break;
            case IMGLYFilterTypeX400:
                [self addFilterSelectButtonWithFilterName:@"X400" action:IMGLYFilterTypeX400];
                break;
            case IMGLYFilterTypeBW:
                [self addFilterSelectButtonWithFilterName:@"B&W" action:IMGLYFilterTypeBW];
                break;
            case IMGLYFilterTypeBWHard:
                [self addFilterSelectButtonWithFilterName:@"1920" action:IMGLYFilterTypeBWHard];
                break;
            case IMGLYFilterTypeLenin:
                [self addFilterSelectButtonWithFilterName:@"Lenin" action:IMGLYFilterTypeLenin];
                break;
            case IMGLYFilterTypeQouzi:
                [self addFilterSelectButtonWithFilterName:@"Quozi" action:IMGLYFilterTypeQouzi];
                break;
            case IMGLYFilterType669:
                [self addFilterSelectButtonWithFilterName:@"Pola 669" action:IMGLYFilterType669];
                break;
            case IMGLYFilterTypePola:
                [self addFilterSelectButtonWithFilterName:@"Pola SX" action:IMGLYFilterTypePola];
                break;
            case IMGLYFilterTypeFood:
                [self addFilterSelectButtonWithFilterName:@"Food" action:IMGLYFilterTypeFood];
                break;
            case IMGLYFilterTypeGlam:
                [self addFilterSelectButtonWithFilterName:@"Glam" action:IMGLYFilterTypeGlam];
                break;
            case IMGLYFilterTypeLord:
                [self addFilterSelectButtonWithFilterName:@"Celsius" action:IMGLYFilterTypeLord];
                break;
            case IMGLYFilterTypeTejas:
                [self addFilterSelectButtonWithFilterName:@"Texas" action:IMGLYFilterTypeTejas];
                break;
            case IMGLYFilterTypeEarlyBird:
                [self addFilterSelectButtonWithFilterName:@"Morning" action:IMGLYFilterTypeEarlyBird];
                break;
            case IMGLYFilterTypeLomo:
                [self addFilterSelectButtonWithFilterName:@"Lomo" action:IMGLYFilterTypeLomo];
                break;
            case IMGLYFilterTypeGobblin:
                [self addFilterSelectButtonWithFilterName:@"Gobblin" action:IMGLYFilterTypeGobblin];
                break;
            case IMGLYFilterTypeSinCity:
                [self addFilterSelectButtonWithFilterName:@"Sin" action:IMGLYFilterTypeSinCity];
                break;
            case IMGLYFilterTypeSketch:
                [self addFilterSelectButtonWithFilterName:@"Pencil" action:IMGLYFilterTypeSketch];
                break;
            case IMGLYFilterTypeMellow:
                [self addFilterSelectButtonWithFilterName:@"Mellow" action:IMGLYFilterTypeMellow];
                break;
            case IMGLYFilterTypeSunny:
                [self addFilterSelectButtonWithFilterName:@"Sunny" action:IMGLYFilterTypeSunny];
                break;
            case IMGLYFilterTypeA15:
                [self addFilterSelectButtonWithFilterName:@"15" action:IMGLYFilterTypeA15];
                break;
            case IMGLYFilterTypeSemiRed:
                [self addFilterSelectButtonWithFilterName:@"Semi Red" action:IMGLYFilterTypeSemiRed];
                break;
            case IMGLYFilterTypeNone:
                [self addFilterSelectButtonWithFilterName:@"None" action:IMGLYFilterTypeNone];
                break;
            default:
                break;
        }
    }
}

- (void)addFilterSelectButtonWithFilterName:(NSString *)filterName action:(IMGLYFilterType)filterType {
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(filterButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = filterType;
    button.layer.cornerRadius = 4;
    button.clipsToBounds = YES;

    IMGLYFilterSelectorButtonMetadata *filterSelectorButtonMetadata = [[IMGLYFilterSelectorButtonMetadata alloc] init];
    filterSelectorButtonMetadata.filterType = filterType;
    filterSelectorButtonMetadata.filterName = filterName;

    NSString *key = [NSString stringWithFormat:@"%i", filterType];
    _dictionary[key] = filterSelectorButtonMetadata;
    
    [_scrollView addSubview:button];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = filterName;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithWhite:1.0F alpha:0.0F];
    label.font = [UIFont fontWithName:@"Avenir-Heavy"  size:11.0];

    [_scrollView addSubview:label];
}

- (void)rearrangeViews {
    int xOffset = 5;

    for (NSUInteger index = 0; index < [_scrollView.subviews count]; ++index) {
        UIImageView *imageView = _scrollView.subviews[index];
        imageView.frame = CGRectMake(xOffset, kIMGLYPreviewImageOffset, 62, 62);

        ++index;

        UILabel *label = _scrollView.subviews[index];
        label.frame = CGRectMake(xOffset, 62 + kIMGLYPreviewImageOffset, 62, kIMGLYPreviewImageTextHeight);
        xOffset += (62 + kIMGLYPreviewImageDistance);
    }

    CGFloat contentHeight = ([_scrollView.subviews count] / 2.0f) * (62 + kIMGLYPreviewImageDistance);
    _scrollView.contentSize = CGSizeMake(contentHeight, 1.0f);
}

#pragma mark Adjusting the Visiblity

- (void)toggleVisible {
    CGFloat newAlpha = IMGLYEqualFloats(self.alpha, 0.0f) ? 1.0f : 0.0f;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = newAlpha;
    }];
}

- (void)activateButton:(UIButton *)clickedButton {
    self.tickImageView.center = clickedButton.center;
    [UIView animateWithDuration:kActivationDuration animations:^{
        clickedButton.alpha = 0.4;
    }];
}

- (void)hideBackground {
    self.gradientView.hidden = YES;
}

#pragma mark Actions

- (void)filterButtonTouchedUpInside:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(filterSelectorView:didSelectFilterType:)]) {
        IMGLYFilterType filterType = (IMGLYFilterType)button.tag;
        [self.delegate filterSelectorView:self didSelectFilterType:filterType];
    }
    [self autoscrollLeftIfNeededFromXPosition:button.frame.origin.x];
    [self autoscrollRightIfNeededFromXPosition:button.frame.origin.x + button.frame.size.width];
    if (button != _lastClickedFilterButton) {
        [self reactivateLastClickedButton];
        [self activateButton:button];
        self.lastClickedFilterButton = button;
    }
}

- (void)autoscrollLeftIfNeededFromXPosition:(CGFloat)xPosition {
    CGFloat bottonPositionOnScreenX = xPosition - self.scrollView.contentOffset.x;
    if (bottonPositionOnScreenX < self.previewImageSize ) {
        CGFloat cellWidth = (self.previewImageSize + kIMGLYPreviewImageDistance);
        CGFloat cellNumber = self.scrollView.contentOffset.x / cellWidth;
        cellNumber = floorf(cellNumber);
        if (bottonPositionOnScreenX <= (kIMGLYPreviewImageDistance / 2.0)) {
            cellNumber--;
        }
        CGFloat newOffsetX = cellNumber * cellWidth ;
        newOffsetX = MAX(0.0, newOffsetX);
        [self.scrollView setContentOffset:CGPointMake(newOffsetX, 0.0) animated:YES];
    }
}

- (void)autoscrollRightIfNeededFromXPosition:(CGFloat)xPosition {
    CGFloat bottonPositionOnScreenX = xPosition - self.scrollView.contentOffset.x;
    if (bottonPositionOnScreenX > (self.scrollView.frame.size.width - self.previewImageSize)) {
        CGFloat cellWidth = (self.previewImageSize + kIMGLYPreviewImageDistance);
        CGFloat cellNumber = self.scrollView.contentOffset.x / cellWidth;
        cellNumber = ceilf(cellNumber) + 1;
        CGFloat newOffsetX = cellNumber * cellWidth ;
        newOffsetX = MIN(self.scrollView.contentSize.width -  self.scrollView.frame.size.width, newOffsetX);
        [self.scrollView setContentOffset:CGPointMake(newOffsetX, 0.0) animated:YES];
    }
}


#pragma mark Handling Rotation

- (void)rotatePortraitModeUpsideDown {
    [self rotateToAngle:M_PI];
}

- (void)rotatePortraitOrientation {
    [self rotateToAngle:0.0f];
}

- (void)rotateLanscapeLeftMode {
    [self rotateToAngle:M_PI_2];
}

- (void)rotateLanscapeRightMode {
    [self rotateToAngle:-M_PI_2];
}

- (void)rotateToAngle:(CGFloat)angle {
    for (NSUInteger index = 0; index < [self.scrollView.subviews count]; index += 2) {
        UIImageView *imageView = self.scrollView.subviews[index];
        imageView.transform = CGAffineTransformMakeRotation(angle);
    }
}

#pragma mark Generating Preview Images

- (void)generatePreviewsForImage:(UIImage *)image {
    dispatch_async(_contextQueue, ^{
        UIImage *resizedImage = [self scaleAndRotateImage:image];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:resizedImage];
        
        for (NSUInteger index = 0; index < [self.scrollView.subviews count] - 2; index += 2) {
            UIButton *button = self.scrollView.subviews[index];
            NSString *key = [NSString stringWithFormat:@"%i", button.tag];
            IMGLYFilterSelectorButtonMetadata *filterSelectorButtonMetadata = self.dictionary[key];
            IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
            IMGLYFilterOperation *operation = [[IMGLYFilterOperation alloc] init];
            operation.filterType = filterSelectorButtonMetadata.filterType;
            [job addOperation:(IMGLYOperation *)operation];
            [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
            UIImage *filtredImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [button setImage:filtredImage forState:UIControlStateNormal];
            });
        }
    });
}


- (void)generateStaticPreviewsForImage:(UIImage *)image {
    UIImage *resizedImage = [self scaleAndRotateImage:image];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:resizedImage];

    for (NSUInteger index = 0; index < [self.scrollView.subviews count] - 2; index += 2) {
        UIButton *button = self.scrollView.subviews[index];
        NSString *key = [NSString stringWithFormat:@"%i", button.tag];
        IMGLYFilterSelectorButtonMetadata *filterSelectorButtonMetadata = self.dictionary[key];
        IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
        IMGLYFilterOperation *operation = [[IMGLYFilterOperation alloc] init];
        operation.filterType = filterSelectorButtonMetadata.filterType;
        [job addOperation:(IMGLYOperation *)operation];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
        UIImage *filtredImage = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
        filterSelectorButtonMetadata.staticPreviewImage = filtredImage;
        self.dictionary[key] = filterSelectorButtonMetadata;
        [button setImage:filtredImage forState:UIControlStateNormal];
    }
}


- (void)setPreviewImagesToDefault {
    for (NSUInteger index = 0; index < [self.scrollView.subviews count] - 2; index += 2) {
        UIButton *button = self.scrollView.subviews[index];
        NSString *key = [NSString stringWithFormat:@"%i", button.tag];
        IMGLYFilterSelectorButtonMetadata *filterSelectorButtonMetadata = self.dictionary[key];
        [button setImage:filterSelectorButtonMetadata.staticPreviewImage forState:UIControlStateNormal];
    }
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {    
    CGImageRef imageRef = image.CGImage;
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);

    CGRect bounds = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
    CGFloat const kMaxImageHeight = self.previewImageSize * [UIScreen mainScreen].scale;
    CGFloat const kMaxImageWidth = kMaxImageHeight;
    if (imageWidth > kMaxImageWidth || imageHeight > kMaxImageHeight) {
        bounds.size.height = kMaxImageHeight;
        bounds.size.width = kMaxImageWidth;
    }
    
    CGFloat scaleRatio = bounds.size.width / imageWidth;
    CGFloat boundHeight;
    UIImageOrientation imageoOrientation = image.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(imageoOrientation) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0f, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0f, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0f * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (imageoOrientation == UIImageOrientationRight || imageoOrientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -imageHeight, 0.0f);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0.0f, -imageHeight);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0.0f, 0.0f, imageWidth, imageHeight), imageRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (NSString *)getSelectedFilterNameForType:(IMGLYFilterType)filterType {
    NSString *key = [NSString stringWithFormat:@"%i", filterType];
    IMGLYFilterSelectorButtonMetadata *filterSelectorButtonMetadata = self.dictionary[key];
    return filterSelectorButtonMetadata.filterName;
}

#pragma mark - active / inactive handling
- (void)reactivateLastClickedButton {
    if (self.lastClickedFilterButton != nil) {
        [UIView animateWithDuration:kActivationDuration animations:^{
            self.lastClickedFilterButton.alpha = 1.0;
        }];
    }
}

@end
