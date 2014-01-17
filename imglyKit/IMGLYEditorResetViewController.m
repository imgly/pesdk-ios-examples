//
// IMGLYEditorResetViewController.m
// imglyKit
// 
// Created by Carsten Przyluczky on 23.10.13.
// Copyright (c) 2013 9elements GmbH. All rights reserved.
//


#import "IMGLYEditorResetViewController.h"
#import "UINavigationController+IMGLYAdditions.h"
#import "IMGLYEditorViewController.h"

@interface IMGLYEditorResetViewController () <UIAlertViewDelegate>

@end

@implementation IMGLYEditorResetViewController

#pragma mark - init
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithImageProvider:imageProvider];
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message:@"Are you sure ? Reset will discard all changes."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",
                                                            nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // OK Button tapped ?
    if(buttonIndex == 1) {
        // get the index of the visible VC on the stack
        int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
        // get a reference to the previous VC
        id prevVC = [self.navigationController.viewControllers objectAtIndex:currentVCIndex - 1];

        if(prevVC != nil) {
            if([prevVC respondsToSelector:@selector(resetAllChanges)]) {
                [prevVC performSelector:@selector(resetAllChanges)];
            }
        }
    }
    [[self navigationController] imgly_fadePopViewController];
}

@end
