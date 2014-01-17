//
//  IMGLYNavigationBar.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 30.07.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYNavigationBar.h"

#import "UIImage+IMGLYKitAdditions.h"

@implementation IMGLYNavigationBar

+ (void)initialize {
    if (self != [IMGLYNavigationBar class])
        return;
    
    [self configureAppearance];
}

+ (void)configureAppearance {
    UIImage *backgroundImage = [UIImage imgly_imageNamed:@"newnavbar"];
    [[self appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];

    [[self appearance] setBarStyle:UIBarStyleBlack];
}

@end
