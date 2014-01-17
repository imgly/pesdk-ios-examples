
//
//  IMGLYEditorTextMenu.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorTextMenu.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "IMGLYEditorColorButton.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kButtonYPosition = 22;
static const CGFloat kMenuHeight = 95;
static const CGFloat kButtonXPositionOffset = 5;
static const CGFloat kButtonDisance = 10;
static const CGFloat kButtonSideLength = 50;

@interface IMGLYEditorTextMenu()

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation IMGLYEditorTextMenu

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

- (void)commonInit {
    self.autoresizesSubviews = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self configureColorArray];
    [self configureColorButtons];
}

- (void)configureColorArray {
    /* these are the values of the web version
     '#FFFFFF', '#000000', '#ec3713',
     '#fcc00b', '#0b6af9', '#a9e90e'*/
    _colorArray = @[[UIColor whiteColor],
                    [UIColor blackColor],
                    [UIColor colorWithRed:(CGFloat)0xec / 255.0 green:(CGFloat)0x37 / 255.0 blue:(CGFloat)0x13 / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0xfc / 255.0 green:(CGFloat)0xc0 / 255.0 blue:(CGFloat)0x0b / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0xa9 / 255.0 green:(CGFloat)0xe9 / 255.0 blue:(CGFloat)0x0e / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0x0b / 255.0 green:(CGFloat)0x6a / 255.0 blue:(CGFloat)0xf9 / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0xff / 255.0 green:(CGFloat)0xff / 255.0 blue:(CGFloat)0x00 / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0xb5 / 255.0 green:(CGFloat)0xe5 / 255.0 blue:(CGFloat)0xff / 255.0 alpha:1],
                    [UIColor colorWithRed:(CGFloat)0xff / 255.0 green:(CGFloat)0xb5 / 255.0 blue:(CGFloat)0xe0 / 255.0 alpha:1]];
}

- (void)configureColorButtons {
    _buttonArray = [[NSMutableArray alloc] init];
    for (UIColor *color in _colorArray) {
        IMGLYEditorColorButton *button = [[IMGLYEditorColorButton alloc] initWithFrame:CGRectZero];
        [self addSubview:button];
        [button addTarget:self
                   action:@selector(colorButtonTouchedUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
        [_buttonArray addObject:button];
        button.backgroundColor = color;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutColorButtons];
}

- (void)layoutColorButtons {
    CGFloat xPosition = kButtonXPositionOffset;
    for (NSUInteger i = 0;i < self.colorArray.count; i++) {
        IMGLYEditorColorButton *button =  [self.buttonArray objectAtIndex:i];
        button.frame = CGRectMake(xPosition,
                                  kButtonYPosition,
                                  kButtonSideLength,
                                  kButtonSideLength);
        button.shadowLayer.frame = button.frame;
        xPosition += (kButtonDisance + kButtonSideLength);
    }
    self.contentSize = CGSizeMake(xPosition + kButtonDisance, 0);
}

#pragma mark - button selection

- (void)colorButtonTouchedUpInside:(UIButton *)button {
    if(self.menuDelegate) {
        [self.menuDelegate selectedColor:button.backgroundColor];
    }
}

@end
