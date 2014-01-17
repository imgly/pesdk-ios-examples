//
//  IMGLYEditorOrientationMenu.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 21.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorOrientationMenu.h"

#import "IMGLYDefaultEditorImageProvider.h"
#import "UIImage+IMGLYKitAdditions.h"

static const CGFloat kButtonYPosition = 20;
static const CGFloat kMenuHeight = 95;
static const CGFloat kLabelXPositionOffset = -31;
static const CGFloat kLabelYPosition = 42;
static const CGFloat kOverlayWidth = 80;
static const CGFloat kButtonMargin = 23;
static const CGFloat kLabelMargin = 22;


@interface IMGLYEditorOrientationMenu()

@property (nonatomic, strong) UIButton *flipHorizontalButton;
@property (nonatomic, strong) UIButton *flipVerticalButton;
@property (nonatomic, strong) UIButton *rotateLeftButton;
@property (nonatomic, strong) UIButton *rotateRightButton;
@property (nonatomic, strong) UILabel *flipHorizontalLabel;
@property (nonatomic, strong) UILabel *flipVerticalLabel;
@property (nonatomic, strong) UILabel *rotateLeftLabel;
@property (nonatomic, strong) UILabel *rotateRightLabel;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;

@end

@implementation IMGLYEditorOrientationMenu

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

- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider{
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
    [self configureButons];
    [self configureLabels];
}

- (void)configureButons {
    _rotateLeftButton = [self addButtonWithImage:[_imageProvider rotateLeftIcon] action:@selector(rotateLeftTouchedUpInside:)];
    _rotateRightButton = [self addButtonWithImage:[_imageProvider rotateRightIcon] action:@selector(rotateRightTouchedUpInside:)];
    _flipVerticalButton = [self addButtonWithImage:[_imageProvider flipVerticalIcon] action:@selector(flipVerticalTouchedUpInside:)];
    _flipHorizontalButton = [self addButtonWithImage:[_imageProvider flipHorizontalIcon] action:@selector(flipHorizontalTouchedUpInside:)];
}

- (void)configureLabels {
    _rotateLeftLabel = [self addLabelWithText:@"Rotate L"];
    _rotateRightLabel = [self addLabelWithText:@"Rotate R"];
    _flipVerticalLabel = [self addLabelWithText:@"Flip V"];
    _flipHorizontalLabel = [self addLabelWithText:@"Flip H"];
}

- (UILabel *)addLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               100,
                                                               50)];
    label.text = text;
    [self styleLabel:label];
    [self addSubview:label];
    return label;
}

- (UIButton *)addButtonWithImage:(UIImage *)image action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, (CGFloat)image.size.width, kMenuHeight - kButtonYPosition);
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
    return overlay;
}

- (void)styleLabel:(UILabel *)label {
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];;
    label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    label.font = [UIFont fontWithName:@"Avenir-Heavy"  size:13.0];
}

- (void)layoutSubviews {
    [self layoutButtons];
    [self layoutLabels];
}

- (void)layoutButtons {
    CGFloat midX = self.frame.size.width / 2.0;
    self.rotateLeftButton.frame = CGRectMake(midX - 2.0 * kOverlayWidth  + kButtonMargin,
                                      kButtonYPosition,
                                      self.rotateLeftButton.imageView.image.size.width,
                                      self.rotateLeftButton.imageView.image.size.height);
    self.rotateRightButton.frame = CGRectMake(midX - kOverlayWidth + kButtonMargin,
                                         kButtonYPosition,
                                         self.rotateRightButton.imageView.image.size.width,
                                         self.rotateRightButton.imageView.image.size.height);
    self.flipVerticalButton.frame = CGRectMake(midX + kButtonMargin,
                                              kButtonYPosition,
                                              self.flipVerticalButton.imageView.image.size.width,
                                              self.flipVerticalButton.imageView.image.size.height);
    self.flipHorizontalButton.frame = CGRectMake(midX + kOverlayWidth + kButtonMargin,
                                              kButtonYPosition,
                                              self.flipHorizontalButton.imageView.image.size.width,
                                              self.flipHorizontalButton.imageView.image.size.height);
}

- (void)layoutLabels {
    CGFloat midX = self.frame.size.width / 2.0;
    self.rotateLeftLabel.frame = CGRectMake(midX - 2.0 * kOverlayWidth + kLabelXPositionOffset + kLabelMargin,
                                     kLabelYPosition,
                                     100,
                                     50);
    self.rotateRightLabel.frame = CGRectMake(midX - kOverlayWidth + kLabelXPositionOffset +  kLabelMargin,
                                        kLabelYPosition,
                                        100,
                                        50);
    self.flipVerticalLabel.frame = CGRectMake(midX + kLabelXPositionOffset +  kLabelMargin,
                                             kLabelYPosition,
                                             100,
                                             50);
    self.flipHorizontalLabel.frame = CGRectMake(midX + kOverlayWidth + kLabelXPositionOffset +  kLabelMargin,
                                             kLabelYPosition,
                                             100,
                                             50);
}


#pragma mark - button handler
- (void)rotateLeftTouchedUpInside:(UIButton *)button  {
    if (self.menuDelegate) {
        [self.menuDelegate rotateLeftTouchedUpInside];
    }
}

- (void)rotateRightTouchedUpInside:(UIButton *)button  {
    if (self.menuDelegate) {
        [self.menuDelegate rotateRightTouchedUpInside];
    }
}

- (void)flipVerticalTouchedUpInside:(UIButton *)button  {
    if (self.menuDelegate) {
        [self.menuDelegate flipVerticalTouchedUpInside];
    }
}

- (void)flipHorizontalTouchedUpInside:(UIButton *)button  {
    if (self.menuDelegate) {
        [self.menuDelegate flipHorizontalTouchedUpInside];
    }   
}

@end
