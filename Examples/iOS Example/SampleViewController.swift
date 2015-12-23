//
//  SampleViewController.swift
//  iOS Example
//
//  Created by Malte Baumann on 21/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit
import imglyKit

class SampleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.tintColor = UIColor(red:0,  green:0.569,  blue:1, alpha:1)
    }
    
    @IBAction func showDefaultCamera(sender: UIButton) {
        // Set a global tint color, that gets inherited by all views
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = UIColor.whiteColor()
        }
        
        UINavigationBar.appearance().tintColor = UIColor.blueColor()
        
        let cameraViewController = IMGLYCameraViewController()
        cameraViewController.maximumVideoLength = 15
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func showDefaultEditor(sender: UIButton) {
        let defaultBlue = view.tintColor
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = UIColor.whiteColor()
        }
        
        let sampleImage = UIImage(named: "sample_image")
        let mainEditorViewController = IMGLYMainEditorViewController()
        mainEditorViewController.highResolutionImage = sampleImage

        let navigationController = IMGLYNavigationController(rootViewController: mainEditorViewController)
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.tintColor = defaultBlue
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showCustomized(sender: UIButton) {
        let whiteColor = UIColor(red:0.941, green:0.980, blue:0.988, alpha:1)
        let redColor = UIColor(red:0.988, green:0.173, blue:0.357, alpha:1)
        let blueColor = UIColor(red:0.243, green:0.769, blue:0.831, alpha:1)
        
        let configuration = IMGLYConfiguration() { builder in
            // Setup global colors
            builder.backgroundColor = whiteColor
            
            // This replaces the SDKs IMGLYFilterEditorViewController, with our own sample subclass
            do {
                try builder.replaceClass(IMGLYStickersEditorViewController.self, replacingClass: SampleStickersEditorSubclass.self, namespace: "iOS_Example")
            } catch {
                print("Class replacement failed.")
            }
            
            // Customize the navigation bar using UIAppearance
            UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: blueColor,
                NSFontAttributeName: UIFont(name: "DINCondensed-Bold", size: 20)! ]
            
            builder.configureCameraViewController { options in
                // Setup a customized datasource, that offers a subset of all available filters
                options.filtersDataSource = IMGLYFiltersDataSource(availableFilters: [ .None, .Orchid, .Pale, .Summer ])
                
                // Enable/Disable some features
                options.cropToSquare = true
                options.showFilterIntensitySlider = false
                options.tapToFocusEnabled = false
                
                // Use closures to customize the different view elements
                options.cameraRollButtonConfigurationClosure = { button in
                    button.layer.borderWidth = 2.0
                    button.layer.borderColor = redColor.CGColor
                }
                
                options.timeLabelConfigurationClosure = { label in
                    label.textColor = redColor
                }
                
                options.recordingModeButtonConfigurationClosure = { button, _ in
                    button.setTitleColor(UIColor.grayColor(), forState: .Normal)
                    button.setTitleColor(redColor, forState: .Selected)
                }
                
                // Force a selfie camera
                options.allowedCameraPositions = [ .Front ]
                
                // Disable flash
                options.allowedFlashModes = [ .Off ]
            }
            
            // Customize the main editor
            builder.configureMainEditorViewController { options in
                options.title = "Selfie-Editor"
                options.allowsPreviewImageZoom = false
                options.editorActionsDataSource = IMGLYMainEditorActionsDataSource(availableActionTypes: [ .Filter, .Stickers, .Orientation, .Contrast, .Text])
            }
            
            // Customize the orientation editors action buttons
            builder.configureOrientationEditorViewController { options in
                options.actionButtonConfigurationClosure = { actionButton, _ in
                    actionButton.textLabel.textColor = UIColor.grayColor()
                }
            }
            
            // Customize the contrast editors slider
            builder.configureContrastEditorViewController { options in
                options.sliderConfigurationClosure = { slider in
                    slider.thumbTintColor = blueColor
                }
            }
            
            // Customize the colors available in the text editor
            builder.configureTextEditorViewController { options in
                options.availableFontColors = [ redColor, blueColor, UIColor.blackColor() ]
            }
        }
        
        let cameraViewController = IMGLYCameraViewController(configuration: configuration)
        
        // Set a global tint color, that gets inherited by all views
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = redColor
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }

}
