//
//  IMGLYEditorColorButton.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorColorButton.h"
#import <QuartzCore/QuartzCore.h>

@interface IMGLYEditorColorButton()

@property (nonatomic, strong) CAGradientLayer *shineLayer;

@end

@implementation IMGLYEditorColorButton

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self styleButton];
}

- (void)styleButton {
    [self setSelected:NO];
    [self setNeedsDisplay];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.layer.borderWidth = 1.0f;
    // Add Shine
    self.shineLayer = [CAGradientLayer layer];
    self.shineLayer.frame =  self.frame;
    self.shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.35f].CGColor,
                         (id)[UIColor colorWithWhite:0.0f alpha:0.35f].CGColor,
                         nil];
    self.shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [self.layer addSublayer:self.shineLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect shineFrame = frame;
    shineFrame.origin = CGPointMake(0.0, 0.0);
    self.shineLayer.frame = shineFrame;
}

@end
