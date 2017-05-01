//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "ViewController.h"
@import PhotoEditorSDK;

@interface ViewController () <PESDKPhotoEditViewControllerDelegate>

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

- (void)configureStickers {
    // Duplicate the first sticker category for demonstration purposes

    PESDKStickerCategory *stickerCategory = PESDKStickerCategory.all.firstObject;
    PESDKStickerCategory.all = [PESDKStickerCategory.all arrayByAddingObject:stickerCategory];
}

- (PESDKConfiguration *)buildConfiguration {
    PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
        // Configure camera
        [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
            // Just enable Photos
            options.allowedRecordingModesAsNSNumbers = @[@(RecordingModePhoto)];
        }];
    }];

    return configuration;
}

#pragma mark - Presentation

- (void)presentCameraViewController {
    [self configureStickers];
    PESDKConfiguration *configuration = [self buildConfiguration];
    PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
    __weak PESDKCameraViewController *weakCameraViewController = cameraViewController;
    cameraViewController.completionBlock = ^(UIImage * _Nullable image, NSURL * _Nullable videoURL) {
        [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:image] animated:YES completion:nil];
    };

    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (PESDKToolbarController *)createPhotoEditViewControllerWithPhoto:(UIImage *)photo {
    PESDKConfiguration *configuration = [self buildConfiguration];
    NSMutableArray<PESDKMenuItem *> *menuItems = [[PESDKMenuItem defaultItemsWithConfiguration:configuration] mutableCopy];
    [menuItems removeLastObject]; // Remove last meu item ('Magic')

    // Create a photo edit view controller
    PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhoto:photo menuItems:menuItems configuration:configuration];
    photoEditViewController.delegate = self;

    // A PhotoEditViewController works in conjunction with a `ToolbarController`, so in almost
    // all cases it should be embedded in one and presented together.
    PESDKToolbarController *toolbarController = [[PESDKToolbarController alloc] init];
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

- (void)photoEditViewController:(PESDKPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidFailToGeneratePhoto:(PESDKPhotoEditViewController *)photoEditViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController *)photoEditviewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
