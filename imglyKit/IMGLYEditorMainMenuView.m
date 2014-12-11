//
//  IMGLYEditorMainMenuView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorMainMenuView.h"

#import "IMGLYDefaultEditorImageProvider.h"
#import "IMGLYEditorBrightnessViewController.h"
#import "IMGLYEditorContrastViewController.h"
#import "IMGLYEditorCropViewController.h"
#import "IMGLYEditorEnhancementViewController.h"
#import "IMGLYEditorFilterViewController.h"
#import "IMGLYEditorResetViewController.h"
#import "IMGLYEditorSaturationViewController.h"
#import "IMGLYEditorTextViewController.h"
#import "IMGLYMainMenuEntryMetaData.h"

static const CGFloat kButtonWidth = 73;
static const CGFloat kLabelXPositionOffset = -20;
static const CGFloat kLabelYPosition = 42;

@interface IMGLYEditorMainMenuView ()
 
@property (nonatomic, strong) NSArray *metaDataArray;
@property (nonatomic, strong) NSMutableDictionary *buttonToMetaDataDictionary;
@property (nonatomic, strong) id<IMGLYEditorImageProvider> imageProvider;
@property (nonatomic, strong) UIButton *magicButton; // we need to keep a reference to this button cos we need to change its state

@end

@implementation IMGLYEditorMainMenuView

- (instancetype)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    _imageProvider = imageProvider;
    [self commonInit];
    return self;
}

- (void)setMagicActive {
    if (self.magicButton != nil) {
        [self.magicButton setImage:[self.imageProvider magicActiveButtonIcon] forState:UIControlStateNormal];
    }
}

- (void)setMagicInActive {
    if (self.magicButton != nil) {
        [self.magicButton setImage:[self.imageProvider magicButtonIcon] forState:UIControlStateNormal];
    }
}


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

    [self commonInit];
    return self;
}

- (void) configureMetaDataArray {
    _metaDataArray = [NSArray arrayWithObjects:
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Magic"
                                                               image:[_imageProvider magicButtonIcon]
                                                 viewControllerClass:[IMGLYEditorEnhancementViewController  class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Filters"
                                                                 image:[_imageProvider filterIcon]
                                                   viewControllerClass:[IMGLYEditorFilterViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Crop"
                                                             image:[_imageProvider cropIcon]
                                                   viewControllerClass:[IMGLYEditorCropViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Brightness"
                                                             image:[_imageProvider brightnessIcon]
                                                   viewControllerClass:[IMGLYEditorBrightnessViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Contrast"
                                                             image:[_imageProvider contrastIcon]
                                                   viewControllerClass:[IMGLYEditorContrastViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Saturation"
                                                             image:[_imageProvider saturationIcon]
                                                   viewControllerClass:[IMGLYEditorSaturationViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Text"
                                                             image:[_imageProvider textIcon]
                                                   viewControllerClass:[IMGLYEditorTextViewController class] ],
                      [[IMGLYMainMenuEntryMetaData alloc] initWithText:@"Reset"
                                                               image:[_imageProvider resetButtonIcon]
                                                 viewControllerClass:[IMGLYEditorResetViewController class] ],
                      nil
                      ];
}

- (void)commonInit {
    _magicButton = nil;
    if  (_imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultEditorImageProvider alloc] init];
    }
    self.autoresizesSubviews = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self configureUserInterface];
}

- (void)configureUserInterface {
    _buttonToMetaDataDictionary = [[NSMutableDictionary alloc] init];
    [self configureMetaDataArray];
    [self configureMenuItems];
}

- (void)configureMenuItems {
    CGFloat xPosition = 0;
    for (IMGLYMainMenuEntryMetaData *metaData in _metaDataArray) {
        [self configureButtonWithMetaData:metaData xPosition:xPosition];
        [self configureLabelWithMetaData:metaData xPosition:xPosition];
        xPosition += kButtonWidth;
    }
}

- (void)configureButtonWithMetaData:(IMGLYMainMenuEntryMetaData *) metaData xPosition:(CGFloat)xPosition {
    UIButton *button = [self configureAndAddMenuButtonWithXPosition:xPosition
                                                              image:metaData.image];
    button.tag = xPosition;
    if ( metaData.viewControllerClass == [IMGLYEditorEnhancementViewController class]) {
        _magicButton = button;
    }
    [_buttonToMetaDataDictionary setObject:metaData forKey:[@(button.tag) stringValue]];
}

- (void)configureLabelWithMetaData:(IMGLYMainMenuEntryMetaData *) metaData xPosition:(CGFloat)xPosition {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xPosition + kLabelXPositionOffset,
                                                               kLabelYPosition,
                                                               100,
                                                               50)];
    label.text = metaData.text;
    [self styleLabel:label];
    [self addSubview:label];
}

- (UIButton *)configureAndAddMenuButtonWithXPosition:(CGFloat)xPosition
                                               image:(UIImage *)image {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    CGRect frame = button.frame;
    frame.origin.x = xPosition;
    frame.origin.y = 10;
    frame.size.width = kButtonWidth - 10;        // lets have some room between buttons
    frame.size.height = image.size.height + 20;  // here we blow up that frame so the button is better to hit
    button.frame = frame;
    button.enabled = YES;
    button.userInteractionEnabled = YES;
    [self addSubview:button];
    [button addTarget:self
               action:@selector(menuButtonTouchedUpInside:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - event delegation
- (void)menuButtonTouchedUpInside:(UIButton *)button {
    if (self.menuDelegate) {
        IMGLYMainMenuEntryMetaData *metaData = [self.buttonToMetaDataDictionary objectForKey:[@(button.tag) stringValue]];
        [self.menuDelegate mainMenuButtonTouchedUpInsideWithViewControllerClass:metaData.viewControllerClass];
    }
}

- (void)layoutSubviews {
    self.contentSize = CGSizeMake((self.metaDataArray.count ) * kButtonWidth,
                                  self.frame.size.height);
}

- (void)styleLabel:(UILabel *)label {
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.8f alpha:1.0f];;
    label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    label.font = [UIFont fontWithName:@"Avenir-Heavy"  size:13.0];
}
@end
