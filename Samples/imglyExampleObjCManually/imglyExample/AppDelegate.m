//
//  AppDelegate.m
//  imglyExample
//
//  Created by Sascha Schwabbauer on 16/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "imglyExample-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // Backend example
    UIImage *image = [UIImage imageNamed:@"photo-1423439793616-f2aa4356b37e.jpeg"];
    IMGLYLomo100Filter *lomo100Filter = (IMGLYLomo100Filter *)[[IMGLYInstanceFactory sharedInstance] effectFilterWithType:IMGLYFilterTypeLomo100];
    
    IMGLYTextFilter *textFilter = [[IMGLYInstanceFactory sharedInstance] textFilter];
    textFilter.text = @"ABC";
    textFilter.fontScaleFactor = 0.3;
    textFilter.color = [UIColor redColor];
    
    __unused UIImage *processedImage = [IMGLYPhotoProcessor processWithUIImage:image filters:@[lomo100Filter, textFilter]];
    
    // Frontend example
    IMGLYCameraViewController *cameraViewController = [[IMGLYCameraViewController alloc] init];
    __weak IMGLYCameraViewController *weakCameraViewController = cameraViewController;
    
    cameraViewController.completionBlock = ^(UIImage *image) {
        // Instantiate an IMGLYEditorMainDialogViewController
        IMGLYEditorMainDialogViewController *editorViewController = [[IMGLYEditorMainDialogViewController alloc] init];
        
        // Set the completion block of the IMGLYEditorMainDialogViewController, this will contain the altered image
        editorViewController.completionBlock = ^(IMGLYEditorResult result, UIImage *image) {
            if (result == IMGLYEditorResultDone) {
                // This is where you get the altered image
                NSLog(@"%@", image);
                
                // Optionally save to album
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        };
        
        // Pass the image that was captured by the IMGLYCameraViewController
        editorViewController.hiResImage = image;
        // Pass the filter that was selected in the IMGLYCameraViewController
        editorViewController.initialFilterType = weakCameraViewController.cameraView.filterSelectorView.activeFilterType;
        
        // Present the IMGLYEditorMainDialogViewController modally on the IMGLYCameraViewController
        [weakCameraViewController presentViewController:editorViewController animated:YES completion:nil];
    };
    
    self.window.rootViewController = cameraViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [((IMGLYCameraViewController *)self.window.rootViewController).cameraView setLastImageFromRollAsPreview];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
