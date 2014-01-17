//
// IMGLYCropViewController.m
// imglyKit
// 
// Created by Carsten Przyluczky on 01.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorCropViewController.h"

#import "IMGLYCropOperation.h"
#import "IMGLYDefaultEditorImageProvider.h"
#import "IMGLYEditorCropMenu.h"
#import "IMGLYPhotoProcessor.h"
#import "IMGLYProcessingJob.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "UINavigationController+IMGLYAdditions.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat kMinimumGestureAreaSize = 44.0; // every view used for gestures should be at least this big
static const CGFloat kMinimumCropSize = 50.0;
static const CGFloat kCropNavbarHeight = 44.0;
static const CGFloat kCropMenuViewHeight = 95.0;
static const CGFloat kBackgroundGrayValue =  34.0 / 255.0;

@interface IMGLYEditorCropViewController ()  <UIGestureRecognizerDelegate, IMGLYEditorCropMenuDelegate>

@property (nonatomic, strong) UIView *transparentRectView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIView *rightLineView;
@property (nonatomic, strong) UIView *leftLineView;
@property (nonatomic, strong) UIImageView *topLeftAnchorView;
@property (nonatomic, strong) UIImageView *topRightAnchorView;
@property (nonatomic, strong) UIImageView *bottomLeftAnchorView;
@property (nonatomic, strong) UIImageView *bottomRightAnchorView;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) UIImage *anchorImage;
@property (nonatomic, assign) CGFloat selectionRatio;
@property (nonatomic, strong) UIView *topView; // holds navbar and so on
@property (nonatomic, strong) UIView *middleView; // holds image selection and so on
@property (nonatomic, strong) IMGLYEditorCropMenu *bottomView; // holds the edit controls
@property (nonatomic, assign) CGFloat cropRectLeftBound;
@property (nonatomic, assign) CGFloat cropRectTopBound;
@property (nonatomic, assign) CGFloat cropRectRightBound;
@property (nonatomic, assign) CGFloat cropRectBottomBound;
@property (nonatomic, assign) CGPoint dragOffset;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;
@property (nonatomic, assign) BOOL initialCropRectNeedsToBeCalculated;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end

@implementation IMGLYEditorCropViewController

@synthesize inputImage = _inputImage;

- (id)initWithCropRect:(CGRect) cropRect {
    self = [super init];
    if (self == nil)
        return nil;
    [self commonInitWithRect:cropRect];
    return self;
}

- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    [self commonInitWithRect:CGRectZero];
    [self setInitialCropRect];
    return self;
}

- (void)commonInitWithRect:(CGRect)rect {
    _initialCropRectNeedsToBeCalculated = NO;
    _selectionMode = IMGLYSelectionModeFree;
    _cropRect = rect;
    _selectionRatio = 4.0 / 3.0;
    [self configureGUI];
}


- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithImageProvider:imageProvider];
    if (self == nil)
        return nil;
    self.imageProvider = imageProvider;
    [self commonInitWithRect:CGRectZero];
    return self;
}


#pragma mark - configuration of GUI
- (void)configureGUI {
    if(self.imageProvider == nil) {
        self.imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    }
    [self configureBackground];
    [self configureMiddleView];
    [self configureBottomView];
    [self configurePreview];
    [self configureLines];
    [self configureTransparentRectView];
    [self configureAnchors];
    [self addGestureRecognizerToAnchors];
    [self addGestureRecognizerToTransparentView];
    [self setSelectionMode:IMGLYSelectionModeFree];
}

- (void)configureBackground {
    self.view.backgroundColor = [UIColor colorWithRed:kBackgroundGrayValue
                                                green:kBackgroundGrayValue
                                                 blue:kBackgroundGrayValue
                                                alpha:1.0];
}

- (void)configureMiddleView {
    _middleView = [[UIView alloc] initWithFrame:CGRectMake(0,
            0,
            self.view.bounds.size.width,
            self.view.bounds.size.height - kCropNavbarHeight)];
    [self.view addSubview:_middleView];
}

- (void)configureBottomView {
    _bottomView = [[IMGLYEditorCropMenu alloc] initWithFrame:CGRectZero];
    _bottomView.menuDelegate = self;
    [self.view addSubview:_bottomView];
}

- (void)configureTransparentRectView {
    _transparentRectView = [[UIView alloc] initWithFrame:CGRectZero];
    _transparentRectView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    [_middleView addSubview:_transparentRectView];
}

- (void)addMaskRectView {
    CGRect bounds = CGRectMake(0, 0, _middleView.frame.size.width, _middleView.frame.size.height);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_cropRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];

    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;

    _transparentRectView.layer.mask = maskLayer;
    _transparentRectView.frame = bounds;
}

- (void)configurePreview {
    self.imagePreview = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  _middleView.frame.size.width,
                                                                  _middleView.frame.size.height)];
    self.imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    [_middleView addSubview:self.imagePreview];
    if(_inputImage != nil) {
        self.imagePreview.image = _inputImage;
    }
}

- (void)configureLines {
    [self configureTopLineView];
    [self configureLeftLineView];
    [self configureRightLineView];
    [self configureBottomLineView];
}

- (void)configureTopLineView {
    _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _topLineView.backgroundColor = [UIColor colorWithRed:1.0
                                                   green:1.0
                                                    blue:1.0
                                                   alpha:1.0];
    [_middleView addSubview:_topLineView];
}

- (void)configureBottomLineView {
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomLineView.backgroundColor = [UIColor colorWithRed:1.0
                                                      green:1.0
                                                       blue:1.0
                                                      alpha:1.0];
    [_middleView addSubview:_bottomLineView];
}

- (void)configureLeftLineView {
    _leftLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _leftLineView.backgroundColor = [UIColor colorWithRed:1.0
                                                    green:1.0
                                                     blue:1.0
                                                    alpha:1.0];
    [_middleView addSubview:_leftLineView];
}

- (void)configureRightLineView {
    _rightLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _rightLineView.backgroundColor = [UIColor colorWithRed:1.0
                                                     green:1.0
                                                      blue:1.0
                                                     alpha:1.0];
    [_middleView addSubview:_rightLineView];
}

- (void)configureAnchors {
    _anchorImage = [self.imageProvider cropDragPointImage];
    _topLeftAnchorView = [self createAnchorWithImage:_anchorImage];
    _topRightAnchorView = [self createAnchorWithImage:_anchorImage];
    _bottomLeftAnchorView = [self createAnchorWithImage:_anchorImage];
    _bottomRightAnchorView = [self createAnchorWithImage:_anchorImage];
}

- (UIImageView *)createAnchorWithImage:(UIImage *)image {
    UIImageView *anchor = [[UIImageView alloc] initWithImage:image];
    anchor.contentMode = UIViewContentModeCenter;
    if(image.size.width < kMinimumGestureAreaSize) {
        anchor.frame = CGRectMake(0, 0, kMinimumGestureAreaSize, kMinimumGestureAreaSize);
    }
    [_middleView addSubview:anchor];
    return  anchor;
}

#pragma mark - layouting

- (void)layoutPreview {
    self.imagePreview.frame = CGRectMake(0,
            0,
            self.view.bounds.size.width,
            self.view.bounds.size.height - kCropMenuViewHeight);
}

- (void)layoutMiddleView {
    self.middleView.frame = CGRectMake(0,
            0,
            self.view.bounds.size.width,
            self.view.bounds.size.height - kCropMenuViewHeight);

}
- (void)layoutBottomView {
    self.bottomView.frame = CGRectMake(0,
            self.view.frame.size.height - kCropMenuViewHeight ,
            self.view.frame.size.width,
            kCropMenuViewHeight);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutBottomView];
    [self layoutMiddleView];
    [self layoutPreview];
    [self layoutViewsForCropRect];
    [self reCalculateCropRectBounds];
    if (self.initialCropRectNeedsToBeCalculated) {
        self.initialCropRectNeedsToBeCalculated = NO;
        [self setInitialCropRect];
        [self layoutViewsForCropRect];
    }
}

- (void)layoutViewsForCropRect {
    self.transparentRectView.frame = _middleView.frame;
    [self layoutLines];
    [self layoutAnchors];
    [self addMaskRectView];
}

#pragma mark lines
- (void)layoutLines {
    self.leftLineView.frame = CGRectMake(self.cropRect.origin.x,
            self.cropRect.origin.y,
            1.0,
            self.cropRect.size.height);
    self.rightLineView.frame = CGRectMake(self.cropRect.origin.x + self.cropRect.size.width - 1.0,
            self.cropRect.origin.y,
            1.0,
            self.cropRect.size.height);
    self.topLineView.frame = CGRectMake(self.cropRect.origin.x ,
            self.cropRect.origin.y,
            self.cropRect.size.width,
            1.0);
    self.bottomLineView.frame = CGRectMake(self.cropRect.origin.x ,
            self.cropRect.origin.y + self.cropRect.size.height - 1.0,
            self.cropRect.size.width,
            1.0);
}

#pragma mark anchor
- (void)layoutAnchors {
    self.topLeftAnchorView.center = CGPointMake(_cropRect.origin.x, _cropRect.origin.y);
    self.topRightAnchorView.center = CGPointMake(_cropRect.origin.x + _cropRect.size.width , _cropRect.origin.y);
    self.bottomLeftAnchorView.center = CGPointMake(_cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height );
    self.bottomRightAnchorView.center = CGPointMake(_cropRect.origin.x + _cropRect.size.width , _cropRect.origin.y + _cropRect.size.height );
}

#pragma mark gesture recognizer

- (void)addGestureRecognizerToTransparentView {
    _transparentRectView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    [_transparentRectView addGestureRecognizer:panGestureRecognizer];
}

- (void)addGestureRecognizerToAnchors {
    [self addGestureRecognizerToAnchor:_bottomRightAnchorView];
    [self addGestureRecognizerToAnchor:_topLeftAnchorView];
    [self addGestureRecognizerToAnchor:_bottomLeftAnchorView];
    [self addGestureRecognizerToAnchor:_topRightAnchorView];
}

- (void)addGestureRecognizerToAnchor:(UIImageView *)anchor {
    anchor.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGestureRecognizer.delegate = self;
    [anchor addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - Pan handling
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.view == self.bottomRightAnchorView) {
        [self handlePanOnBottomRight:recognizer];
    }
    else if(recognizer.view == self.topLeftAnchorView) {
        [self handlePanOnTopLeft:recognizer];
    }
    else if(recognizer.view == self.bottomLeftAnchorView) {
        [self handlePanOnBottomLeft:recognizer];
    }
    else if(recognizer.view == self.topRightAnchorView) {
        [self handlePanOnTopRight:recognizer];
    }
    else if(recognizer.view == self.transparentRectView) {
        [self handlePanOnTransparentView:recognizer];
    }
}

- (void) calculateDragOffsetOnNewDrag:(UIPanGestureRecognizer *) recognizer {
    CGPoint location = [recognizer locationInView:self.transparentRectView];
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        self.dragOffset = CGPointMake(
                location.x - self.cropRect.origin.x,
                location.y - self.cropRect.origin.y);
    }
}

- (CGPoint)clampedLocationToBounds:(CGPoint) location {
    CGRect rect = self.cropRect;

    CGFloat locationX = location.x;
    CGFloat locationY = location.y;

    // calculate new Boundaries
    CGFloat left = locationX - self.dragOffset.x;
    CGFloat right = left + rect.size.width;
    CGFloat top = locationY - self.dragOffset.y;
    CGFloat bottom = top + rect.size.height;

    if(left < self.cropRectLeftBound) {
       locationX = self.cropRectLeftBound + self.dragOffset.x;
    }
    if(right > self.cropRectRightBound) {
        locationX = self.cropRectRightBound - self.cropRect.size.width  + self.dragOffset.x;
    }
    if(top < self.self.cropRectTopBound) {
        locationY = self.cropRectTopBound + self.dragOffset.y;
    }
    if(bottom > self.cropRectBottomBound) {
        locationY = self.cropRectBottomBound - self.cropRect.size.height + self.dragOffset.y;
    }
    return CGPointMake(locationX, locationY);
}

- (void)handlePanOnTransparentView:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.transparentRectView];
    if([self isPoint:location inRect:self.cropRect]) {
        [self calculateDragOffsetOnNewDrag:recognizer];
            CGPoint newLocation = [self clampedLocationToBounds:location];
            //CGPoint newLocation = location;
            CGRect rect = self.cropRect;
            rect.origin.x = newLocation.x - self.dragOffset.x;
            rect.origin.y = newLocation.y - self.dragOffset.y;
            self.cropRect = rect;
            [self layoutViewsForCropRect];
    }

}

- (void)handlePanOnTopLeft:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:_middleView];
    CGFloat sizeX = fabsf( self.bottomRightAnchorView.center.x - location.x );
    CGFloat sizeY = fabsf( self.bottomRightAnchorView.center.y - location.y );

    [self applyMinimumAreaRuleToWidth:&sizeX height:&sizeY];
    [self reCalulateSizeForTopLeftAnchor:&sizeX height:&sizeY];

    CGPoint center = self.topLeftAnchorView.center;
    center.x += self.cropRect.size.width - sizeX;
    center.y += self.cropRect.size.height - sizeY;
    self.topLeftAnchorView.center = center;
    [self recalculateCropRectFromTopLeftAnchor];
    [self layoutViewsForCropRect];
}

- (void)reCalulateSizeForTopLeftAnchor:(CGFloat *)sizeX height:(CGFloat *)sizeY {
    if(self.selectionMode != IMGLYSelectionModeFree) {
        *sizeY = *sizeY * self.selectionRatio;
        if (*sizeY > *sizeX) {
            *sizeX = *sizeY;
        }
        *sizeY = *sizeX / self.selectionRatio;

        if( (self.bottomRightAnchorView.center.x - *sizeX) < self.cropRectLeftBound) {
            *sizeX = self.bottomRightAnchorView.center.x - self.cropRectLeftBound;
            *sizeY = *sizeX / self.selectionRatio;
        }
        if( (self.bottomRightAnchorView.center.y - *sizeY) < self.cropRectTopBound) {
            *sizeY = self.bottomRightAnchorView.center.y - self.cropRectTopBound;
            *sizeX = *sizeY * self.selectionRatio;
        }
    }
    else {
        if( (self.bottomRightAnchorView.center.x - *sizeX) < self.cropRectLeftBound) {
            *sizeX = self.bottomRightAnchorView.center.x - self.cropRectLeftBound;
        }
        if( (self.bottomRightAnchorView.center.y - *sizeY) < self.cropRectTopBound) {
            *sizeY = self.bottomRightAnchorView.center.y - self.cropRectTopBound;
        }
    }
}

- (void)handlePanOnBottomRight:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:_middleView];
    CGFloat sizeX = fabsf( self.topLeftAnchorView.center.x - location.x );
    CGFloat sizeY = fabsf( self.topLeftAnchorView.center.y - location.y );

    [self applyMinimumAreaRuleToWidth:&sizeX height:&sizeY];
    [self reCalulateSizeForBottomRightAnchor:&sizeX height:&sizeY];

    CGPoint center = self.bottomRightAnchorView.center;
    center.x -= self.cropRect.size.width - sizeX;
    center.y -= self.cropRect.size.height - sizeY;
    self.bottomRightAnchorView.center = center;
    [self recalculateCropRectFromTopLeftAnchor];
    [self layoutViewsForCropRect];
}

- (void)reCalulateSizeForBottomRightAnchor:(CGFloat *)sizeX height:(CGFloat *)sizeY {
    if(self.selectionMode != IMGLYSelectionModeFree) {
        *sizeY = *sizeY * self.selectionRatio;
        if (*sizeY > *sizeX) {
            *sizeX = *sizeY;
        }
        if((self.topLeftAnchorView.center.x + *sizeX) > self.cropRectRightBound) {
            *sizeX = self.cropRectRightBound - self.topLeftAnchorView.center.x;
        }
        *sizeY = *sizeX / self.selectionRatio;
        if((self.topLeftAnchorView.center.y + *sizeY) > self.cropRectBottomBound) {
            *sizeY = self.cropRectBottomBound - self.topLeftAnchorView.center.y;
            *sizeX = *sizeY * self.selectionRatio;
        }
    }
    else {
        if((self.topLeftAnchorView.center.x + *sizeX) > self.cropRectRightBound) {
            *sizeX = self.cropRectRightBound - self.topLeftAnchorView.center.x;
        }
        if((self.topLeftAnchorView.center.y + *sizeY) >  self.cropRectBottomBound) {
            *sizeY =  self.cropRectBottomBound - self.topLeftAnchorView.center.y;
        }
    }
}

- (void)handlePanOnTopRight:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.middleView];
    CGFloat sizeX = fabsf( self.bottomLeftAnchorView.center.x - location.x );
    CGFloat sizeY = fabsf( self.bottomLeftAnchorView.center.y - location.y );

    [self applyMinimumAreaRuleToWidth:&sizeX height:&sizeY];
    [self reCalulateSizeForTopRightAnchor:&sizeX height:&sizeY];

    CGPoint center = self.topRightAnchorView.center;
    center.x = self.bottomLeftAnchorView.center.x + sizeX;
    center.y = self.bottomLeftAnchorView.center.y - sizeY;
    self.topRightAnchorView.center = center;
    [self recalculateCropRectFromTopRightAnchor];
    [self layoutViewsForCropRect];
}

- (void)reCalulateSizeForTopRightAnchor:(CGFloat *)sizeX height:(CGFloat *)sizeY {
    if(self.selectionMode != IMGLYSelectionModeFree) {
        *sizeY = *sizeY * self.selectionRatio;
        if (*sizeY > *sizeX) {
            *sizeX = *sizeY;
        }
        if((self.topLeftAnchorView.center.x + *sizeX) > self.cropRectRightBound) {
            *sizeX = self.cropRectRightBound - self.topLeftAnchorView.center.x;
        }
        *sizeY = *sizeX / self.selectionRatio;
        if( (self.bottomRightAnchorView.center.y - *sizeY) < self.cropRectTopBound) {
            *sizeY = self.bottomRightAnchorView.center.y - self.cropRectTopBound;
            *sizeX = *sizeY * self.selectionRatio;
        }
   }
    else {
        if((self.topLeftAnchorView.center.x + *sizeX) > self.cropRectRightBound) {
            *sizeX = self.cropRectRightBound - self.topLeftAnchorView.center.x;
        }
        if( (self.bottomRightAnchorView.center.y - *sizeY) < self.cropRectTopBound) {
            *sizeY =  self.bottomRightAnchorView.center.y - self.cropRectTopBound;
        }
    }
}

- (void)handlePanOnBottomLeft:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.middleView];
    CGFloat sizeX = fabsf( self.topRightAnchorView.center.x - location.x );
    CGFloat sizeY = fabsf( self.topRightAnchorView.center.y - location.y );

    [self applyMinimumAreaRuleToWidth:&sizeX height:&sizeY];
    [self reCalulateSizeForBottomLeftAnchor:&sizeX height:&sizeY];

    CGPoint center = self.bottomLeftAnchorView.center;
    center.x = self.topRightAnchorView.center.x - sizeX;
    center.y = self.topRightAnchorView.center.y + sizeY;
    self.bottomLeftAnchorView.center = center;
    [self recalculateCropRectFromTopRightAnchor];
    [self layoutViewsForCropRect];
}

- (void)reCalulateSizeForBottomLeftAnchor:(CGFloat *)sizeX height:(CGFloat *)sizeY {
    if(self.selectionMode != IMGLYSelectionModeFree) {
        *sizeY = *sizeY * self.selectionRatio;
        if (*sizeY > *sizeX) {
            *sizeX = *sizeY;
        }
        *sizeY = *sizeX / self.selectionRatio;

        if( (self.topRightAnchorView.center.x - *sizeX) < self.cropRectLeftBound) {
            *sizeX = self.topRightAnchorView.center.x - self.cropRectLeftBound;
            *sizeY = *sizeX / self.selectionRatio;
        }

        if((self.topRightAnchorView.center.y + *sizeY) > self.cropRectBottomBound) {
            *sizeY = self.cropRectBottomBound - self.topRightAnchorView.center.y;
            *sizeX = *sizeY * self.selectionRatio;
        }
    }
    else {
        if( (self.topRightAnchorView.center.x - *sizeX) < self.cropRectLeftBound) {
            *sizeX = self.topRightAnchorView.center.x - self.cropRectLeftBound;
        }
        if((self.topRightAnchorView.center.y + *sizeY) > self.cropRectBottomBound) {
            *sizeY = self.cropRectBottomBound - self.topRightAnchorView.center.y;
        }
    }
}

- (void)applyMinimumAreaRuleToWidth:(CGFloat *)sizeX  height:(CGFloat *)sizeY {
    if(*sizeX < kMinimumCropSize) {
        *sizeX = kMinimumCropSize;
    }

    if(*sizeY < kMinimumCropSize) {
        *sizeY = kMinimumCropSize;
    }
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

- (void)reCalculateCropRectBounds {
    CGSize scaledImageSize =  [self scaledImageSize];
    self.cropRectLeftBound = (self.middleView.frame.size.width - scaledImageSize.width) / 2.0;
    self.cropRectRightBound = self.middleView.frame.size.width - self.cropRectLeftBound;
    self.cropRectTopBound = (self.middleView.frame.size.height - scaledImageSize.height) / 2.0;
    self.cropRectBottomBound = self.middleView.frame.size.height - self.cropRectTopBound;
}

#pragma mark - Getter/Setter
- (void)setInputImage:(UIImage *)inputImage {
    _inputImage = inputImage;
    self.imagePreview.image = _inputImage;
    [self reCalculateCropRectBounds];
    self.initialCropRectNeedsToBeCalculated = YES;
}


- (UIImage *)inputImage {
    return _inputImage;
}

- (void)calculateRatioForSelectionMode:(IMGLYSelectionMode)selectionMode {
    if(selectionMode == IMGLYSelectionMode4to3) {
        _selectionRatio = 4.0 / 3.0;
    }
    else if(selectionMode == IMGLYSelectionMode1to1) {
        _selectionRatio = 1.0;
    }
    else if(selectionMode == IMGLYSelectionMode16to9) {
        _selectionRatio = 16.0 / 9.0;
    }
    if(selectionMode != IMGLYSelectionModeFree) {
        CGPoint screenCenter = self.imagePreview.center;
        CGSize imagePreviewSize = self.imagePreview.frame.size;
        CGFloat rectWidth = imagePreviewSize.width;
        CGFloat rectHeight = rectWidth / _selectionRatio;

        self.cropRect = CGRectMake(screenCenter.x - rectWidth / 2.0,
                screenCenter.y - rectHeight / 2.0,
                rectWidth,
                rectHeight);
        [self layoutViewsForCropRect];
    }
}

- (void)setSelectionMode:(IMGLYSelectionMode)selectionMode {
    _selectionMode = selectionMode;
    [self calculateRatioForSelectionMode:selectionMode];
    [[self bottomView] setSelectionMode: selectionMode];
}

- (void) setInitialCropRect {
    CGPoint screenCenter = self.imagePreview.center;
    CGSize size = CGSizeMake(self.cropRectRightBound - self.cropRectLeftBound,
            self.cropRectBottomBound - self.cropRectTopBound);
    CGFloat rectWidth = size.width;
    CGFloat rectHeight = rectWidth ;
    if (size.width > size.height) {
         rectHeight = size.height;
         rectWidth  = rectHeight;
    }
    self.cropRect = CGRectMake(screenCenter.x - rectWidth / 2.0,
            screenCenter.y - rectHeight / 2.0,
            rectWidth,
            rectHeight);
}


#pragma mark - selection frame calculation

- (void)recalculateCropRectFromTopLeftAnchor {
    self.cropRect = CGRectMake(self.topLeftAnchorView.center.x,
            self.topLeftAnchorView.center.y,
            self.bottomRightAnchorView.center.x - self.topLeftAnchorView.center.x,
            self.bottomRightAnchorView.center.y - self.topLeftAnchorView.center.y);
}

- (void)recalculateCropRectFromTopRightAnchor {
    self.cropRect = CGRectMake(self.bottomLeftAnchorView.center.x ,
            self.topRightAnchorView.center.y,
            self.topRightAnchorView.center.x - self.bottomLeftAnchorView.center.x,
            self.bottomLeftAnchorView.center.y - self.topRightAnchorView.center.y);
}

- (void)freeFormButtonTouchedUpInside {
    [self setSelectionMode:IMGLYSelectionModeFree];
}

- (void)squareFormButtonTouchedUpInside {
    [self setSelectionMode:IMGLYSelectionMode1to1];
}

- (void)ratio4to3FormButtonTouchedUpInside {
    [self setSelectionMode:IMGLYSelectionMode4to3];
}

- (void)ratio16to9FormButtonTouchedUpInside {
    [self setSelectionMode:IMGLYSelectionMode16to9];
}

#pragma mark - tools
- (BOOL) isPoint:(CGPoint)point inRect:(CGRect)rect {
    CGFloat top = rect.origin.y;
    CGFloat bottom = top + rect.size.height;
    CGFloat left = rect.origin.x;
    CGFloat right = left + rect.size.width;

    BOOL inRectXAxis = point.x > left && point.x < right;
    BOOL inRectYAxis = point.y > top && point.y < bottom;
    return (inRectXAxis && inRectYAxis);
}

- (CGRect) normalizedCropRect {
    CGFloat boundWidth = self.cropRectRightBound - self.cropRectLeftBound;
    CGFloat boundHeight = self.cropRectBottomBound - self.cropRectTopBound;
    CGFloat x = (self.cropRect.origin.x - self.cropRectLeftBound) / boundWidth;
    CGFloat y = (self.cropRect.origin.y - self.cropRectTopBound) / boundHeight;
    CGRect normalizedRect = CGRectMake(x,
                                       y,
                                       self.cropRect.size.width / boundWidth,
                                       self.cropRect.size.height / boundHeight);
    return normalizedRect;
}

#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    [[self navigationController] imgly_fadePopViewController];
    if(self.completionHandler) {
        IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
        IMGLYCropOperation *operation = [[IMGLYCropOperation alloc] init];
        operation.rect = [self normalizedCropRect];
        [job addOperation:(IMGLYOperation *)operation];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
        [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
        self.completionHandler(IMGLYEditorViewControllerResultDone,
                               [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage],
                               job);
    }
}

@end
