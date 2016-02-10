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

    private let whiteColor = UIColor(red:0.941, green:0.980, blue:0.988, alpha:1)
    private let redColor = UIColor(red:0.988, green:0.173, blue:0.357, alpha:1)
    private let blueColor = UIColor(red:0.243, green:0.769, blue:0.831, alpha:1)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.tintColor = UIColor(red:0,  green:0.569,  blue:1, alpha:1)
    }

    @IBAction func showDefaultCamera(sender: UIButton) {
        let defaultBlue = view.tintColor
        // Set a global tint color, that gets inherited by all views
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = UIColor.whiteColor()
        }

        UINavigationBar.appearance().tintColor = defaultBlue

        let cameraViewController = CameraViewController()
        presentViewController(cameraViewController, animated: true, completion: nil)
    }

    @IBAction func showDefaultEditor(sender: UIButton) {
        let defaultBlue = view.tintColor
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = UIColor.whiteColor()
        }

        let sampleImage = UIImage(named: "sample_image")
        let mainEditorViewController = MainEditorViewController()
        mainEditorViewController.highResolutionImage = sampleImage

        let navigationController = NavigationController(rootViewController: mainEditorViewController)
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.tintColor = defaultBlue
        presentViewController(navigationController, animated: true, completion: nil)
    }

    @IBAction func showCustomized(sender: UIButton) {

        let configuration = Configuration() { builder in
            // Setup global colors
            builder.backgroundColor = self.whiteColor

            // This replaces the SDKs FilterEditorViewController, with our own sample subclass
            do {
                try builder.replaceClass(StickersEditorViewController.self, replacingClass: SampleStickersEditorSubclass.self, namespace: "iOS_Example")
            } catch {
                print("Class replacement failed.")
            }

            // Customize the navigation bar using UIAppearance
            UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: self.blueColor,
                NSFontAttributeName: UIFont(name: "DINCondensed-Bold", size: 20)! ]

            self.customizeCameraController(builder)
            self.customizeMainEditorViewController(builder)
            self.customizeOrientationViewController(builder)
            self.customizeContrastSliders(builder)
            self.customizeTextEditorView(builder)
        }

        let cameraViewController = CameraViewController(configuration: configuration)

        // Set a global tint color, that gets inherited by all views
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.tintColor = redColor
        }
        presentViewController(cameraViewController, animated: true, completion: nil)
    }

    // MARK: - customization

    private func customizeCameraController(builder: ConfigurationBuilder) {
        builder.configureCameraViewController { options in
            // Setup a customized datasource, that offers a subset of all available filters
            options.filtersDataSource = FiltersDataSource(availableFilters: [ .None, .Orchid, .Pale, .Summer ])

            // Enable/Disable some features
            options.cropToSquare = true
            options.maximumVideoLength = 15
            options.showFilterIntensitySlider = false
            options.tapToFocusEnabled = false

            // Use closures to customize the different view elements
            options.cameraRollButtonConfigurationClosure = { button in
                button.layer.borderWidth = 2.0
                button.layer.borderColor = self.redColor.CGColor
            }

            options.timeLabelConfigurationClosure = { label in
                label.textColor = self.redColor
            }

            options.recordingModeButtonConfigurationClosure = { button, _ in
                button.setTitleColor(UIColor.grayColor(), forState: .Normal)
                button.setTitleColor(self.redColor, forState: .Selected)
            }

            // Force a selfie camera
            options.allowedCameraPositions = [ .Front ]

            // Disable flash
            options.allowedFlashModes = [ .Off ]
        }
    }

    private func customizeMainEditorViewController(builder: ConfigurationBuilder) {
        // Customize the main editor
        builder.configureMainEditorViewController { options in
            options.title = "Selfie-Editor"
            options.allowsPreviewImageZoom = false
            options.editorActionsDataSource = MainEditorActionsDataSource(availableActionTypes: [ .Filter, .Stickers, .Orientation, .Contrast, .Text])
        }
    }

    private func customizeOrientationViewController(builder: ConfigurationBuilder) {
        builder.configureOrientationEditorViewController { options in
            options.actionButtonConfigurationClosure = { actionButton, _ in
                actionButton.textLabel.textColor = UIColor.grayColor()
            }
        }
    }

    private func customizeContrastSliders(builder: ConfigurationBuilder) {
        builder.configureContrastEditorViewController { options in
            options.sliderConfigurationClosure = { slider in
                slider.thumbTintColor = self.blueColor
            }
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func customizeTextEditorView(builder: ConfigurationBuilder) {
        builder.configureTextEditorViewController { options in
            options.availableFontColors = [ self.redColor, self.blueColor, UIColor.blackColor() ]
            options.fontSelectorFontColor = self.redColor
            options.fontQuickSelectorButtonConfigurationClosure = { button in
                button.labelColor = UIColor.grayColor()
            }
            options.fontSelectorButtonConfigurationClosure = { button in
                button.labelColor = UIColor.grayColor()
            }
            options.actionButtonConfigurationClosure = { button, action in
                // swiftlint:disable force_cast
                switch action {
                case .SelectFont:
                    (button as! TextCaptionButton).textLabel.textColor = UIColor.grayColor()
                case .SelectColor:
                    fallthrough
                case .SelectBackgroundColor:
                    fallthrough
                case .BringToFront:
                    (button as! ImageCaptionButton).textLabel.textColor = UIColor.grayColor()
                case .RejectFont:
                    fallthrough
                case .RejectColor:
                    fallthrough
                case .AcceptColor:
                    fallthrough
                case .AcceptFont:
                    fallthrough
                case .Delete:
                    fallthrough
                case .Add:
                    (button as! UIButton).backgroundColor = UIColor.grayColor()
                }
                // swiftlint:enable force_cast
            }
            options.pullableViewConfigurationClosure = { pullableView in
                pullableView.handleBackgroundColor = self.redColor
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
