//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016 9elements GmbH <contact@9elements.com>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import UIKit
import imglyKit

private enum Selection: Int {
    case camera = 0
    case editor = 1
    case embeddedEditor = 2
    case customized = 3
}

class ViewController: UITableViewController {

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case Selection.camera.rawValue:
            presentCameraViewController()
        case Selection.editor.rawValue:
            presentPhotoEditViewController()
        case Selection.embeddedEditor.rawValue:
            pushPhotoEditViewController()
        case Selection.customized.rawValue:
            presentCustomizedCameraViewController()
        default:
            break
        }
    }

    // MARK: - Configuration

    private func buildConfiguration() -> Configuration {
        let configuration = Configuration() { builder in
            // Configure camera
            builder.configureCameraViewController() { options in
                // Just enable Photos
                options.allowedRecordingModes = [.photo]
            }

            // Get a reference to the sticker data source
            builder.configureStickerToolController() { options in
                options.stickerCategoryDataSourceConfigurationClosure = { dataSource in
                    // Duplicate the first sticker category for demonstration purposes
                    if let stickerCategory = dataSource.stickerCategories?.first {
                        dataSource.stickerCategories = [stickerCategory, stickerCategory]
                    }
                }
            }
        }

        return configuration
    }

    // MARK: - Presentation

    private func presentCameraViewController() {
        let configuration = buildConfiguration()
        let cameraViewController = CameraViewController(configuration: configuration)
        cameraViewController.completionBlock = { [unowned cameraViewController] image, videoURL in
            if let image = image {
                cameraViewController.present(self.createPhotoEditViewController(with: image), animated: true, completion: nil)
            }
        }

        present(cameraViewController, animated: true, completion: nil)
    }

    private func createPhotoEditViewController(with photo: UIImage) -> ToolbarController {
        let configuration = buildConfiguration()
        var menuItems = MenuItem.defaultItems(with: configuration)
        menuItems.removeLast() // Remove last menu item ('Magic')

        // Create a photo edit view controller
        let photoEditViewController = PhotoEditViewController(photo: photo, menuItems: menuItems, configuration: configuration)
        photoEditViewController.delegate = self

        // A PhotoEditViewController works in conjunction with a `ToolbarController`, so in almost
        // all cases it should be embedded in one and presented together.
        let toolbarController = ToolbarController()
        toolbarController.push(photoEditViewController, animated: false)

        return toolbarController
    }

    private func presentPhotoEditViewController() {
        guard let photo = UIImage(named: "LA.jpg") else {
            return
        }

        present(createPhotoEditViewController(with: photo), animated: true, completion: nil)
    }

    private func pushPhotoEditViewController() {
        guard let photo = UIImage(named: "LA.jpg") else {
            return
        }

        navigationController?.pushViewController(createPhotoEditViewController(with: photo), animated: true)
    }

    private func presentCustomizedCameraViewController() {
        let configuration = Configuration { builder in
            // Setup global colors
            builder.backgroundColor = self.whiteColor
            builder.separatorColor = self.redColor
            builder.accessoryViewBackgroundColor = UIColor.lightGray
            
            self.customizeCameraController(builder)
            self.customizePhotoEditorViewController(builder)
            self.customizeTextTool()
        }
        
        let cameraViewController = CameraViewController(configuration: configuration)
        
        // Set a global tint color, that gets inherited by all views
        if let window = UIApplication.shared.delegate?.window! {
            window.tintColor = redColor
        }
        
        cameraViewController.completionBlock = { image, url in
            let toolbarController = ToolbarController()
            toolbarController.view.tintColor = UIColor(red: 0.11, green: 0.44, blue: 1.00, alpha: 1.00)
            
            let photoEditViewController = PhotoEditViewController(photo: image!, configuration: configuration)
            photoEditViewController.delegate = self
            
            toolbarController.push(photoEditViewController, animated: false)
            toolbarController.toolbar.backgroundColor = UIColor.gray
            
            cameraViewController.present(toolbarController, animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    // MARK: - Customization
    
    fileprivate let whiteColor = UIColor(red: 0.941, green: 0.980, blue: 0.988, alpha: 1)
    fileprivate let redColor = UIColor(red: 0.988, green: 0.173, blue: 0.357, alpha: 1)
    fileprivate let blueColor = UIColor(red: 0.243, green: 0.769, blue: 0.831, alpha: 1)

    fileprivate func customizeTextTool() {
        let fonts = [
            Font(displayName: "Arial", fontName: "ArialMT"),
            Font(displayName: "Helvetica", fontName: "Helvetica"),
            Font(displayName: "Avenir", fontName: "Avenir-Heavy"),
            Font(displayName: "Chalk", fontName: "Chalkduster"),
            Font(displayName: "Copperplate", fontName: "Copperplate"),
            Font(displayName: "Noteworthy", fontName: "Noteworthy-Bold")
        ]
        
        FontImporter.fonts = fonts
    }
    
    fileprivate func customizeCameraController(_ builder: ConfigurationBuilder) {
        builder.configureCameraViewController { options in
            // Enable/Disable some features
            options.cropToSquare = true
            options.showFilterIntensitySlider = false
            options.tapToFocusEnabled = false
            
            // Use closures to customize the different view elements
            options.cameraRollButtonConfigurationClosure = { button in
                button.layer.borderWidth = 2.0
                button.layer.borderColor = self.redColor.cgColor
            }
            
            options.timeLabelConfigurationClosure = { label in
                label.textColor = self.redColor
            }
            
            options.recordingModeButtonConfigurationClosure = { button, _ in
                button.setTitleColor(UIColor.gray, for: .normal)
                button.setTitleColor(self.redColor, for: .selected)
            }
            
            // Force a selfie camera
            options.allowedCameraPositions = [ .front ]
            
            // Disable flash
            options.allowedFlashModes = [ .off ]
        }
    }
    
    fileprivate func customizePhotoEditorViewController(_ builder: ConfigurationBuilder) {
        // Customize the main editor
        builder.configurePhotoEditorViewController { options in
            options.titleViewConfigurationClosure = { titleView in
                if let titleLabel = titleView as? UILabel {
                    titleLabel.text = "Selfie-Editor"
                }
            }
            
            options.actionButtonConfigurationClosure = { cell, action in
                cell.captionTintColor = UIColor.red
            }
        }
    }
    
    func menuItems(with configuration: Configuration) -> [MenuItem] {
        return [
            .tool("Transform", UIImage(named: "ic_crop_48pt", in:  Bundle.imglyKitBundle, compatibleWith: nil)!, TransformToolController(configuration: configuration))
        ]
    }
}

extension ViewController: PhotoEditViewControllerDelegate {
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        dismiss(animated: true, completion: nil)
    }

    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }

    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
}

