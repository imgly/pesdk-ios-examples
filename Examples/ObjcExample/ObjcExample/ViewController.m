#import "ViewController.h"
@import CoreLocation;
@import PhotoEditorSDK;

@interface ViewController () <PESDKPhotoEditViewControllerDelegate>

@property (nonatomic, retain) PESDKTheme *theme;
@property (nonatomic, retain) PESDKOpenWeatherProvider *weatherProvider;

@end

@implementation ViewController

@synthesize theme;
@synthesize weatherProvider;

#pragma mark - UIViewController

- (void)viewDidLoad {
  theme = PESDKTheme.dynamic;
  PESDKTemperatureFormat unit = PESDKTemperatureFormatLocale;
  weatherProvider = [[PESDKOpenWeatherProvider alloc] initWithApiKey:nil unit:unit];
  weatherProvider.locationAccessRequestClosure = ^(CLLocationManager * _Nonnull locationManager) {
    [locationManager requestWhenInUseAuthorization];
  };
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self presentPhotoEditViewController];
  } else if (indexPath.row == 1) {
    theme = PESDKTheme.light;
    [self presentPhotoEditViewController];
    theme = PESDKTheme.dynamic;
  } else if (indexPath.row == 2) {
    theme = PESDKTheme.dark;
    [self presentPhotoEditViewController];
    theme = PESDKTheme.dynamic;
  } else if (indexPath.row == 3) {
    [self pushPhotoEditViewController];
  } else if (indexPath.row == 4) {
    [self presentCameraViewController];
  }
}

- (BOOL)prefersStatusBarHidden {
  // Before changing `prefersStatusBarHidden` please read the comment below
  // in `viewDidAppear`.
  return true;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  // This is a workaround for a bug in iOS 13 on devices without a notch
  // where pushing a `UIViewController` (with status bar hidden) from a
  // `UINavigationController` (status bar not hidden or vice versa) would
  // result in a gap above the navigation bar (on the `UIViewController`)
  // and a smaller navigation bar on the `UINavigationController`.
  //
  // This is the case when a `MediaEditViewController` is embedded into a
  // `UINavigationController` and uses a different `prefersStatusBarHidden`
  // setting as the parent view.
  //
  // Setting `prefersStatusBarHidden` to `false` would cause the navigation
  // bar to "jump" after the view appeared but this seems to be the only chance
  // to fix the layout.
  //
  // For reference see: https://forums.developer.apple.com/thread/121861#378841
  [self.navigationController.view setNeedsLayout];
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
      NSMutableArray<PESDKPhotoEditMenuItem *> *menuItems = [PESDKPhotoEditMenuItem.defaultItems mutableCopy];
      [menuItems removeLastObject]; // Remove last menu item ('Magic')
      options.menuItems = menuItems;
    }];

    // Configure sticker tool
    [builder configureStickerToolController:^(PESDKStickerToolControllerOptionsBuilder * _Nonnull options) {
      // Enable personal stickers
      options.personalStickersEnabled = true;
      // Enable smart weather stickers
      options.weatherProvider = self.weatherProvider;
    }];

    // Configure theme
    builder.theme = self.theme;
  }];

  return configuration;
}

#pragma mark - Presentation

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo {
  return [self createPhotoEditViewControllerWithPhoto:photo and:[[PESDKPhotoEditModel alloc] init]];
}

- (PESDKPhotoEditViewController *)createPhotoEditViewControllerWithPhoto:(PESDKPhoto *)photo and:(PESDKPhotoEditModel *)photoEditModel {
  PESDKConfiguration *configuration = [self buildConfiguration];

  // Create a photo edit view controller
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration photoEditModel:photoEditModel];
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  photoEditViewController.delegate = self;

  return photoEditViewController;
}

- (void)presentPhotoEditViewController {
  NSURL *url = [NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
  [self presentViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES completion:nil];
}

- (void)pushPhotoEditViewController {
  NSURL *url = [NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:url];
  [self.navigationController pushViewController:[self createPhotoEditViewControllerWithPhoto:photo] animated:YES];
}

- (void)presentCameraViewController {
  PESDKConfiguration *configuration = [self buildConfiguration];
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  cameraViewController.locationAccessRequestClosure = ^(CLLocationManager * _Nonnull locationManager) {
    [locationManager requestWhenInUseAuthorization];
  };

  __weak PESDKCameraViewController *weakCameraViewController = cameraViewController;
  cameraViewController.cancelBlock = ^{
    [self dismissViewControllerAnimated:YES completion:nil];
  };
  cameraViewController.completionBlock = ^(PESDKCameraResult * _Nonnull result) {
    if (result.data != nil) {
      PESDKPhoto *photo = [[PESDKPhoto alloc] initWithData:result.data];
      PESDKPhotoEditModel *photoEditModel = [weakCameraViewController photoEditModel];
      [weakCameraViewController presentViewController:[self createPhotoEditViewControllerWithPhoto:photo and:photoEditModel] animated:YES completion:nil];
    }
  };

  [self presentViewController:cameraViewController animated:YES completion:nil];
}

#pragma mark - PhotoEditViewControllerDelegate

- (BOOL)photoEditViewControllerShouldStart:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController task:(PESDKPhotoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

- (void)photoEditViewControllerDidFinish:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController result:(PESDKPhotoEditorResult * _Nonnull)result {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)photoEditViewControllerDidFail:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController error:(PESDKPhotoEditorError * _Nonnull)error {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController {
  if (photoEditViewController.navigationController != nil) {
    [photoEditViewController.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
