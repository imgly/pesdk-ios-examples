//
//  UINavigationController + IMGLYAdditions.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 24.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "UINavigationController+IMGLYAdditions.h"

#import <QuartzCore/QuartzCore.h>

@implementation UINavigationController (Fade)

- (void)imgly_pushFadeViewController:(UIViewController *)viewController {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self pushViewController:viewController animated:NO];
}

- (void)imgly_fadePopViewController {
	CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self popViewControllerAnimated:NO];
}

@end
