//
// IMGLYEditorCropMenu.m
// imglyKit
// 
// Created by Carsten Przyluczky on 01.07.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorCropMenu.h"
#import "IMGLYDefaultEditorImageProvider.h"

#import "UIImage+IMGLYKitAdditions.h"

static const CGFloat kButtonXPositionDistance = 80;
static const CGFloat kButtonXPositionOffset = 21;
static const CGFloat kLabelXPositionOffset = -10;
static const CGFloat kButtonYPosition = 9;
static const CGFloat kLabelYPosition = 47;
static const CGFloat kMenuHeight = 95;

@interface IMGLYEditorCropMenu  ()

@property (nonatomic, assign) CGFloat currentX;
@property (nonatomic, strong) UIView *freeOverlay;
@property (nonatomic, strong) UIView *_1to1Overlay;
@property (nonatomic, strong) UIView *_4to3Overlay;
@property (nonatomic, strong) UIView *_16to9Overlay;
@property (nonatomic, strong) UILabel *freeLabel;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

@end

@implementation IMGLYEditorCropMenu

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    [self commonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    _imageProvider = imageProvider;
    [self commonInit];
    return self;
}

- (id)init {
    self = [super init];
    if (self == nil)
        return nil;

    [self commonInit];
    return self;
}

#pragma mark - Interface configuration
- (void)commonInit {
    if (_imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    }
    _currentX = kButtonXPositionOffset;
    self.autoresizesSubviews = NO;
    [self configureOverlays];
    [self configureButtons];
    [self configureFreeLabel];
    [self configure1to1Label];
    [self configure4to3Label];
    [self configure16to9Label];
}

- (void)configureButtons {
    [self addButtonWithImage:[_imageProvider customRatioIcon] action:@selector(freeFormButtonTouchedUpInside:)];
    [self addButtonWithImage:[_imageProvider oneToOneRatioIcon] action:@selector(squareFormButtonTouchedUpInside:)];
    [self addButtonWithImage:[_imageProvider fourToThreeRatioIcon] action:@selector(ratio4to3FormButtonTouchedUpInside:)];
    [self addButtonWithImage:[_imageProvider sixteenToNineRatioIcon] action:@selector(ratio16to9FormButtonTouchedUpInside:)];
}

- (void)configureFreeLabel {
    _freeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLabelXPositionOffset,
            kLabelYPosition,
            100,
            50)];
    _freeLabel.text = @"Custom";
    [self styleLabel:_freeLabel];
    [self addSubview:_freeLabel];
}

- (void)configure1to1Label {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kLabelXPositionOffset + kButtonXPositionDistance,
            kLabelYPosition,
            100,
            50)];
    label.text = @"1:1";
    [self styleLabel:label];
    [self addSubview:label];
}

- (void)configure4to3Label {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kLabelXPositionOffset + 2.0 * kButtonXPositionDistance,
            kLabelYPosition,
            100,
            50)];
    label.text = @"4:3";
    [self styleLabel:label];
    [self addSubview:label];
}


- (void)configure16to9Label {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(
            kLabelXPositionOffset + 3.0 * kButtonXPositionDistance - 1.0,
            kLabelYPosition,
            100,
            50)];
    label.text = @"16:9";
    [self styleLabel:label];
    [self addSubview:label];
}

- (void)styleLabel:(UILabel *)label {
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];;
    label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    label.font = [UIFont fontWithName:@"Avenir-Heavy"  size:13.0];
}

- (void)addButtonWithImage:(UIImage *)image action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(_currentX,
            0,
            (CGFloat)image.size.width,
            kMenuHeight - kButtonYPosition);

    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    _currentX += kButtonXPositionDistance;
}

#pragma mark - transparent overlays
- (void)configureOverlays {
    CGFloat currentX = 0;
    _freeOverlay = [self createOverlayWithX:currentX width:kButtonXPositionDistance];
    currentX += kButtonXPositionDistance;
    __1to1Overlay = [self createOverlayWithX:currentX width:kButtonXPositionDistance];
    currentX += kButtonXPositionDistance;
    __4to3Overlay = [self createOverlayWithX:currentX width:kButtonXPositionDistance];
    currentX += kButtonXPositionDistance;
    __16to9Overlay = [self createOverlayWithX:currentX width:kButtonXPositionDistance];
}

- (UIView *)createOverlayWithX:(CGFloat)x width:(CGFloat)width {
    CGRect rect = CGRectMake(x, 0, width, kMenuHeight);
    UIView *overlay = [[UIView alloc] initWithFrame:rect];
    overlay.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    overlay.hidden = YES;
    [self addSubview:overlay];

    const CGFloat bottomBoarderHeight = 2;
    UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                        rect.size.height - bottomBoarderHeight,
                                                                        rect.size.width,
                                                                        bottomBoarderHeight)];
    bottomBorderView.backgroundColor = [UIColor colorWithRed:171.0/255 green:192.0/255 blue:254.0/255 alpha:1];
    [overlay addSubview:bottomBorderView];

    return overlay;
}

- (void) hideAllOverlays {
    self.freeOverlay.hidden = YES;
    self._1to1Overlay.hidden = YES;
    self._4to3Overlay.hidden = YES;
    self._16to9Overlay.hidden = YES;
}

#pragma mark - cropMode handling
- (void)setSelectionMode:(IMGLYSelectionMode) cropMode {
    [self hideAllOverlays];
    switch (cropMode) {
        case IMGLYSelectionModeFree:
            self.freeOverlay.hidden = NO;
            break;
        case IMGLYSelectionMode1to1:
            self._1to1Overlay.hidden = NO;
            break;
        case IMGLYSelectionMode4to3:
            self._4to3Overlay.hidden = NO;
            break;
        case IMGLYSelectionMode16to9:
            self._16to9Overlay.hidden = NO;
            break;
    }
}

#pragma mark - layouting
- (void)layoutSubviews {
    _freeLabel.frame =  CGRectMake(kLabelXPositionOffset,
            kLabelYPosition,
            100,
            50);
}

#pragma mark - event delegation
- (void)freeFormButtonTouchedUpInside:(UIButton *)button {
    if(self.menuDelegate) {
        [self.menuDelegate freeFormButtonTouchedUpInside];
    }
}

- (void)squareFormButtonTouchedUpInside:(UIButton *)button {
    if(self.menuDelegate) {
        [self.menuDelegate squareFormButtonTouchedUpInside];
    }
}

- (void)ratio4to3FormButtonTouchedUpInside:(UIButton *)button {
    if(self.menuDelegate) {
        [self.menuDelegate ratio4to3FormButtonTouchedUpInside];
    }
}

- (void)ratio16to9FormButtonTouchedUpInside:(UIButton *)button {
    if(self.menuDelegate) {
        [self.menuDelegate ratio16to9FormButtonTouchedUpInside];
    }
}

@end
