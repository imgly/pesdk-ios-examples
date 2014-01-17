//
//  UINavigationController + IMGLYAdditions.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 24.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Fade)

- (void)imgly_pushFadeViewController:(UIViewController *)viewController;
- (void)imgly_fadePopViewController;

@end
