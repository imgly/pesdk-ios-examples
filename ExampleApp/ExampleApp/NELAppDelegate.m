//
//  NELAppDelegate.m
//  ExampleApp
//
//  Created by Carsten Przyluczky on 07.06.13.
//  Copyright (c) 2013 9elements Gmbh. All rights reserved.
//

#import "NELAppDelegate.h"

#import "NELImageSelectorViewController.h"

#import <imglyKit/IMGLYKit.h>

@implementation NELAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureWindow];
    [self configureCameraViewControllerAsRootViewController];
    return YES;
}

- (void)configureWindow {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    [window makeKeyAndVisible];
    self.window = window;
}

- (void)configureCameraViewControllerAsRootViewController {
    IMGLYCameraViewController *cameraViewController
        = [[IMGLYCameraViewController alloc] initWithAvailableFilterList:[self filterTypes]];

    NELAppDelegate * __weak weakSelf = self;
    cameraViewController.completionHandler =
        ^(IMGLYCameraViewControllerResult result, UIImage *image, IMGLYFilterType filterType) {
            [weakSelf cameraViewControllerCompletedWithResult:result image:image filterType:filterType];
        };

    self.window.rootViewController = cameraViewController;
}

- (void)cameraViewControllerCompletedWithResult:(IMGLYCameraViewControllerResult)result
                                          image:(UIImage *)image
                                     filterType:(IMGLYFilterType)filterType {

    [self presentEditorViewControllerWithImage:image filterType:filterType];
}

- (void)presentEditorViewControllerWithImage:(UIImage *)image filterType:(IMGLYFilterType)filterType {
    IMGLYEditorViewController *editorViewController = [[IMGLYEditorViewController alloc] init];
    editorViewController.filterType = filterType;
    editorViewController.availableFilterList = [self filterTypes];
    editorViewController.inputImage = image;

    NELAppDelegate * __weak weakSelf = self;
    editorViewController.completionHandler =
        ^(IMGLYEditorViewControllerResult result, UIImage *outputImage, IMGLYProcessingJob *job) {
            [weakSelf editorViewControllerCompletedWithResult:result image:outputImage job:job];
        };

    UINavigationController *navigationController
        = [[UINavigationController alloc] initWithNavigationBarClass:[IMGLYNavigationBar class] toolbarClass:Nil];
    [navigationController pushViewController:editorViewController animated:NO];

    [self.window.rootViewController presentViewController:navigationController animated:YES completion:NULL];
}

- (void)editorViewControllerCompletedWithResult:(IMGLYEditorViewControllerResult)result
                                          image:(UIImage *)image
                                            job:(IMGLYProcessingJob *)job {

    if (result == IMGLYEditorViewControllerResultDone)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);

    [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
        IMGLYCameraViewController *cameraViewController = (IMGLYCameraViewController *)self.window.rootViewController;
        [cameraViewController restartCamera];
    }];
}

- (NSArray *)filterTypes {
    return @[
        @(IMGLYFilterTypeNone),
        @(IMGLYFilterType9EK1),
        @(IMGLYFilterType9EK2),
        @(IMGLYFilterType9EK6),
        @(IMGLYFilterType9EKDynamic),
        @(IMGLYFilterTypeFridge),
        @(IMGLYFilterTypeBreeze),
        @(IMGLYFilterTypeOchrid),
        @(IMGLYFilterTypeChestnut),
        @(IMGLYFilterTypeFront),
        @(IMGLYFilterTypeFixie),
        @(IMGLYFilterTypeX400),
        @(IMGLYFilterTypeBW),
        @(IMGLYFilterTypeBWHard),
        @(IMGLYFilterTypeLenin),
        @(IMGLYFilterTypeQouzi),
        @(IMGLYFilterType669),
        @(IMGLYFilterTypePola),
        @(IMGLYFilterTypeFood),
        @(IMGLYFilterTypeGlam),
        @(IMGLYFilterTypeTejas),
        @(IMGLYFilterTypeLomo)
    ];
}

@end
