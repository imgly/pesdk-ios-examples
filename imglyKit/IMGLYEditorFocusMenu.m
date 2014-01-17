//
//  IMGLYEditorFocusMenu.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 08.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorFocusMenu.h"

#import "IMGLYDefaultEditorImageProvider.h"
#import "UIImage+IMGLYKitAdditions.h"

static const CGFloat kButtonYPosition = 19;
static const CGFloat kMenuHeight = 95;
static const CGFloat kLabelXPositionOffset = -31;
static const CGFloat kLabelYPosition = 42;
static const CGFloat kOverlayWidth = 80;
static const CGFloat kButtonMargin = 23;
static const CGFloat kLabelMargin = 22;

@interface IMGLYEditorFocusMenu()

@property (nonatomic, strong) UIView *circleOverlay;
@property (nonatomic, strong) UIView *boxOverlay;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UIButton *boxButton;
@property (nonatomic, strong) UILabel *circleLabel;
@property (nonatomic, strong) UILabel *boxLabel;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

@end

@implementation IMGLYEditorFocusMenu

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [self commonInit];
    return self;
}

- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    
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

- (void)commonInit {
    if (_imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    }
    self.autoresizesSubviews = NO;
    [self configureOverlays];
    [self configureButons];
    [self configureLabels];
}

- (void)configureOverlays {
    _circleOverlay = [self createOverlayWithWidth:kOverlayWidth];
    _boxOverlay = [self createOverlayWithWidth:kOverlayWidth];
}

- (void)configureButons {
    _circleButton = [self addButtonWithImage:[_imageProvider radialFocusIcon] action:@selector(circleButtonTouchedUpInside:)];
    _boxButton = [self addButtonWithImage:[_imageProvider linearFocusIcon] action:@selector(boxButtonTouchedUpInside:)];
}

- (void)configureLabels {
    _circleLabel = [self addLabelWithText:@"Radial"];
    _boxLabel = [self addLabelWithText:@"Linear"];
}

- (UILabel *)addLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    label.text = text;
    [self styleLabel:label];
    [self addSubview:label];
    return label;
}

- (UIButton *)addButtonWithImage:(UIImage *)image  action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (UIView *)createOverlayWithWidth:(CGFloat)width {
    CGRect rect = CGRectMake(0, 0, width, kMenuHeight);
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

- (void)styleLabel:(UILabel *)label {
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];;
    label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    label.font = [UIFont fontWithName:@"Avenir-Heavy"  size:13.0];
}

- (void) hideAllOverlays {
    self.circleOverlay.hidden = YES;
    self.boxOverlay.hidden = YES;
}

- (void)setTiltShiftMode:(IMGLYTiltShiftMode) tiltShiftMode {
    [self hideAllOverlays];
    if (tiltShiftMode == IMGLYTiltShiftModeBox) {
        self.boxOverlay.hidden = NO;
    }
    else if (tiltShiftMode == IMGLYTiltShiftModeCircle) {
        self.circleOverlay.hidden = NO;
    }
}

- (void)layoutSubviews {
    [self layoutOverlays];
    [self layoutButtons];
    [self layoutLabels];
}

- (void)layoutOverlays {
    CGFloat midX = self.frame.size.width / 2.0;
    self.boxOverlay.frame = CGRectMake(midX,
                                   0,
                                   kOverlayWidth,
                                   kMenuHeight);
    self.circleOverlay.frame = CGRectMake(midX - kOverlayWidth,
                                      0,
                                      kOverlayWidth,
                                      kMenuHeight);
}

- (void)layoutButtons {
    CGFloat midX = self.frame.size.width / 2.0;
    self.boxButton.frame = CGRectMake(midX  + kButtonMargin,
                                      kButtonYPosition,
                                      self.boxButton.imageView.image.size.width,
                                      self.boxButton.imageView.image.size.height);
    self.circleButton.frame = CGRectMake(midX - kOverlayWidth + kButtonMargin,
                                      kButtonYPosition,
                                      self.circleButton.imageView.image.size.width,
                                      self.circleButton.imageView.image.size.height);
}

- (void)layoutLabels {
    CGFloat midX = self.frame.size.width / 2.0;
    self.boxLabel.frame = CGRectMake(midX + kLabelXPositionOffset + kLabelMargin,
                                  kLabelYPosition,
                                  100,
                                  50);
    self.circleLabel.frame = CGRectMake(midX - kOverlayWidth + kLabelXPositionOffset +  kLabelMargin,
                                      kLabelYPosition,
                                      100,
                                      50);
}

#pragma mark - button handling
- (void)circleButtonTouchedUpInside:(UIButton *)button {
    if (self.menuDelegate) {
        [self.menuDelegate circleModeTouchedUpInside];
    }
}

- (void)boxButtonTouchedUpInside:(UIButton *)button {
    if (self.menuDelegate) {
        [self.menuDelegate boxModeTouchedUpInside];
    }    
}


@end
