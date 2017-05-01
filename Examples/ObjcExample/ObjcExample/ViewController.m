//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "ViewController.h"
@import imglyKit;

@interface ViewController () <IMGLYPhotoEditViewControllerDelegate>

@end

@implementation ViewController

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self presentCameraViewController];
    } else if (indexPath.row == 1) {
        [self presentPhotoEditViewController];
    } else if (indexPath.row == 2) {
        [self pushPhotoEditViewController];
    }
}

#pragma mark - Configuration

- (IMGLYConfiguration *)buildConfiguration {
    IMGLYConfiguration *configuration = [[IMGLYConfiguration alloc] initWithBuilder:^(IMGLYConfigurationBuilder * _Nonnull builder) {
        // Configure camera
        [builder configureCameraViewController:^(IMGLYCameraViewControllerOptionsBuilder * _Nonnull options) {
            // Just enable Photos
            options.allowedRecordingModesAsNSNumbers = @[@(RecordingModePhoto)];
        }];

        // Get a reference to the sticker data source
        [builder configureStickerToolController:^(IMGLYStickerToolControllerOptionsBuilder * _Nonnull options) {
            options.stickerCategoryDataSourceConfigurationClosure = ^(IMGLYStickerCategoryDataSource * _Nonnull dataSource) {
                // Duplicate the first sticker category for demonstration purposes
                IMGLYStickerCategory *stickerCategory = dataSource.stickerCategories.firstObject;
                dataSource.stickerCategories = @[stickerCategory, stickerCategory];
            };
        }];
    }];

    return configuration;
}

#pragma mark - Presentation

- (void)presentCameraViewController {
    IMGLYConfiguration *configuration = [self buildConfiguration];
    IMGLYCameraViewController *cameraViewController = [[IMGLYCameraViewController alloc] initWithConfiguration:configuration];
    __weak IMGLYCameraViewController *weakCameraViewController = cameraViewController;
    cameraViewController.completionBlock = ^(UIImage * _Nullable image, NSURL * _Nullable videoURL) {
        [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:image] animated:YES completion:nil];
    };

    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (IMGLYToolbarController *)createPhotoEditViewControllerWithPhoto:(UIImage *)photo {
    IMGLYConfiguration *configuration = [self buildConfiguration];
    NSMutableArray<IMGLYBoxedMenuItem *> *menuItems = [[IMGLYBoxedMenuItem boxedDefaultItemsWithConfiguration:configuration] mutableCopy];
    [menuItems removeLastObject]; // Remove last meu item ('Magic')

    // Create a photo edit view controller
    IMGLYPhotoEditViewController *photoEditViewController = [[IMGLYPhotoEditViewController alloc] initWithPhoto:photo menuItems:menuItems configuration:configuration];
    photoEditViewController.delegate = self;

    // A PhotoEditViewController works in conjunction with a `ToolbarController`, so in almost
    // all cases it should be embedded in one and presented together.
    IMGLYToolbarController *toolbarController = [[IMGLYToolbarController alloc] init];
    [toolbarController pushViewController:photoEditViewController animated:NO completion:nil];

    return toolbarController;
}

- (void)presentPhotoEditViewController {
    UIImage *photo = [UIImage imageNamed:@"LA.jpg"];
    [self presentViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES completion:nil];
}

- (void)pushPhotoEditViewController {
    UIImage *photo = [UIImage imageNamed:@"LA.jpg"];
    [self.navigationController pushViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES];
}

#pragma mark - PhotoEditViewControllerDelegate

- (void)photoEditViewController:(IMGLYPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidFailToGeneratePhoto:(IMGLYPhotoEditViewController *)photoEditViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidCancel:(IMGLYPhotoEditViewController *)photoEditviewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
