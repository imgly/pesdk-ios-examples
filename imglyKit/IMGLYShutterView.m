//
//  IMGLYShutterView.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 27.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYShutterView.h"
#import "UIImage+IMGLYKitAdditions.h"
#import "IMGLYDefaultCameraImageProvider.h"

#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(x) (M_PI * (x) / 180.0)

@interface IMGLYShutterView()
{
    double centerX;
    double centerY;
}
@property (nonatomic, strong) id<IMGLYCameraImageProvider>imageProvider;
@end

@implementation IMGLYShutterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        centerX = frame.size.width / 2;
        centerY = frame.size.height / 2;
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYCameraImageProvider>)imageProvider {
    self = [super initWithFrame:frame];
    if (self) {
        _imageProvider = imageProvider;
        centerX = frame.size.width / 2;
        centerY = frame.size.height / 2;
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    if (_imageProvider == nil) {
        _imageProvider = [[IMGLYDefaultCameraImageProvider alloc] init];
    }
    
    for(int i = 0; i <  8; i++)
    {
        double angle = degreesToRadians(i * 45 );
        UIImage *bladeImage = [_imageProvider shutterBladeImage];
        UIImageView *blade = [[UIImageView alloc] initWithImage:bladeImage];
        blade.transform = CGAffineTransformMakeRotation( -angle );
        blade.layer.position = CGPointMake(sin(angle ) *   bladeImage.size.height / 2.0 + centerX, cos(angle ) *   bladeImage.size.height / 2.0 + centerY );
        [self addSubview:blade];
    }
}

- (void) rotateAllBladesBy: (double) angle {
    for( NSUInteger i = 0; i < self.subviews.count; i++) {
        UIImageView *blade = [self.subviews objectAtIndex:i];
        double a = degreesToRadians(((double)i * 45.0)) * -1.0 ;
        double b =  degreesToRadians(angle) ;
        blade.transform = CGAffineTransformMakeRotation( a - b);
    }
}

- (void) openShutter {
    [UIView animateWithDuration:0.2 animations:^{
        [self rotateAllBladesBy:70];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
}

- (void) closeShutter {
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        [self rotateAllBladesBy:0];
    }];
}

@end
