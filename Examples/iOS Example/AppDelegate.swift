//
//  AppDelegate.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 21/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import imglyKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Start with default configuration
        let configuration = IMGLYConfiguration()
        
        // Customize the done button using the configuration block
        configuration.mainEditorViewControllerOptions.rightBarButtonConfigurationClosure = { barButtonItem in
            barButtonItem.tintColor = UIColor.greenColor()
        }
        
        let cameraViewControllerOptions = IMGLYCameraViewControllerOptions()
        cameraViewControllerOptions.backgroundColor = UIColor.lightGrayColor()
        cameraViewControllerOptions.tapToFocusEnabled = false
        cameraViewControllerOptions.allowedCameraPositions = [ .Back ]
        cameraViewControllerOptions.allowedTorchModes = [ .Off ]
        cameraViewControllerOptions.cropToSquare = false
        
        configuration.cameraViewControllerOptions = cameraViewControllerOptions
        
        configuration.textEditorViewControllerOptions.fontPreviewTextColor = UIColor.blueColor()
        configuration.textEditorViewControllerOptions.availableFontColors = [ UIColor.redColor(), UIColor.greenColor() ]
        configuration.textEditorViewControllerOptions.canModifyTextSize = false
        configuration.textEditorViewControllerOptions.canModifyTextColor = false
        
        // Replace IMGLYMainEditorViewController with IMGLYMainEditorSubclassViewController
        do {
            try configuration.replaceClass(IMGLYMainEditorViewController.self, replacingClass: IMGLYMainEditorSubclassViewController.self, namespace: "iOS_Example")
        } catch {
            print("Couldn't replace class")
        }
        
        let cameraViewController = IMGLYCameraViewController(configuration: configuration)
        cameraViewController.maximumVideoLength = 15
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = cameraViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}
