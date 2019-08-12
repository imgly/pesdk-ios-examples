//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016-2019 img.ly GmbH <contact@img.ly>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

#import "ViewController.h"
@import CoreLocation;
@import PhotoEditorSDK;

@interface ViewController () <PESDKPhotoEditViewControllerDelegate>

@property (nonatomic, retain) PESDKTheme *theme;

@end

@implementation ViewController

@synthesize theme;

#pragma mark - UIViewController

- (void)viewDidLoad {
  theme = PESDKTheme.dark;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self presentCameraViewController];
  } else if (indexPath.row == 1) {
    [self presentPhotoEditViewController];
  } else if (indexPath.row == 2) {
    theme = PESDKTheme.light;
    [self presentPhotoEditViewController];
    theme = PESDKTheme.dark;
  } else if (indexPath.row == 3) {
    [self pushPhotoEditViewController];
  }
}

#pragma mark - Configuration

- (PESDKConfiguration *)buildConfiguration {
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure camera
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      // Just enable photos
      options.allowedRecordingModes = @[@(RecordingModePhoto)];
      // Show cancel button
      options.showCancelButton = true;
    }];

    // Configure editor
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      NSMutableArray<PESDKPhotoEditMenuItem *> *menuItems = [[PESDKPhotoEditMenuItem defaultItems] mutableCopy];
      [menuItems removeLastObject]; // Remove last menu item ('Magic')
      options.menuItems = menuItems;
    }];

    // Configure theme
    builder.theme = self.theme;
  }];

  return configuration;
}

#pragma mark - Presentation

- (void)presentCameraViewController {
  PESDKConfiguration *configuration = [self buildConfiguration];
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.locationAccessRequestClosure = ^(CLLocationManager * _Nonnull locationManager) {
    [locationManager requestWhenInUseAuthorization];
  };

  __weak PESDKCameraViewController *weakCameraViewController = cameraViewController;
  cameraViewController.cancelBlock = ^{
    [self dismissViewControllerAnimated:YES completion:nil];
  };
  cameraViewController.completionBlock = ^(UIImage * _Nullable image, NSURL * _Nullable url) {
    if (image != nil) {
      PESDKPhoto *photo = [[PESDKPhoto alloc] initWithImage:image];
      PESDKPhotoEditModel *photoEditModel = [weakCameraViewController photoEditModel];
      [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:photo and:photoEditModel] animated:YES completion:nil];
    }
  };
  cameraViewController.dataCompletionBlock = ^(NSData * _Nullable data) {
    if (data != nil) {
      PESDKPhoto *photo = [[PESDKPhoto alloc] initWithData:data];
      PESDKPhotoEditModel *photoEditModel = [weakCameraViewController photoEditModel];
      [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:photo and:photoEditModel] animated:YES completion:nil];
    }
  };

  [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo {
  return [self createPhotoEditViewControllerWithPhoto:photo and:[[PESDKPhotoEditModel alloc] init]];
}

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo and:(PESDKPhotoEditModel *)photoEditModel {
  PESDKConfiguration *configuration = [self buildConfiguration];

  // Create a photo edit view controller
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration photoEditModel:photoEditModel];
  photoEditViewController.delegate = self;

  return photoEditViewController;
}

- (void)presentPhotoEditViewController {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
  [self presentViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES completion:nil];
}

- (void)pushPhotoEditViewController {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
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
