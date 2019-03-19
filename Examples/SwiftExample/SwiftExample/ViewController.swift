//  This file is part of the PhotoEditor Software Development Kit.
//  Copyright (C) 2016-2019 img.ly GmbH <contact@img.ly>
//  All rights reserved.
//  Redistribution and use in source and binary forms, without
//  modification, are permitted provided that the following license agreement
//  is approved and a legal/financial contract was signed by the user.
//  The license agreement can be found under the following link:
//  https://www.photoeditorsdk.com/LICENSE.txt

import PhotoEditorSDK
import UIKit

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
    let configuration = Configuration { builder in
      // Configure camera
      builder.configureCameraViewController { options in
        // Just enable Photos
        options.allowedRecordingModes = [.photo]
      }
    }

    return configuration
  }

  // MARK: - Presentation

  private func presentCameraViewController() {
    let configuration = buildConfiguration()
    let cameraViewController = CameraViewController(configuration: configuration)
    cameraViewController.dataCompletionBlock = { [unowned cameraViewController] data in
      if let data = data {
        let photo = Photo(data: data)
        cameraViewController.present(self.createPhotoEditViewController(with: photo), animated: true, completion: nil)
      }
    }

    present(cameraViewController, animated: true, completion: nil)
  }

  private func createPhotoEditViewController(with photo: Photo) -> PhotoEditViewController {
    let configuration = buildConfiguration()
    var menuItems = PhotoEditMenuItem.defaultItems
    menuItems.removeLast() // Remove last menu item ('Magic')

    // Create a photo edit view controller
    let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration, menuItems: menuItems)
    photoEditViewController.delegate = self

    return photoEditViewController
  }

  private func presentPhotoEditViewController() {
    guard let url = Bundle.main.url(forResource: "LA", withExtension: "jpg") else {
      return
    }

    let photo = Photo(url: url)
    present(createPhotoEditViewController(with: photo), animated: true, completion: nil)
  }

  private func pushPhotoEditViewController() {
    guard let url = Bundle.main.url(forResource: "LA", withExtension: "jpg") else {
      return
    }

    let photo = Photo(url: url)
    navigationController?.pushViewController(createPhotoEditViewController(with: photo), animated: true)
  }

  private func presentCustomizedCameraViewController() {
    let configuration = Configuration { builder in
      // Setup global colors
      builder.backgroundColor = self.whiteColor
      builder.menuBackgroundColor = UIColor.lightGray

      self.customizeCameraController(builder)
      self.customizePhotoEditorViewController(builder)
      self.customizeTextTool()
    }

    let cameraViewController = CameraViewController(configuration: configuration)

    // Set a global tint color, that gets inherited by all views
    if let window = UIApplication.shared.delegate?.window! {
      window.tintColor = redColor
    }

    cameraViewController.dataCompletionBlock = { data in
      let photo = Photo(data: data!)
      let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
      photoEditViewController.view.tintColor = UIColor(red: 0.11, green: 0.44, blue: 1.00, alpha: 1.00)
      photoEditViewController.toolbar.backgroundColor = UIColor.gray
      photoEditViewController.delegate = self

      cameraViewController.present(photoEditViewController, animated: true, completion: nil)
    }

    present(cameraViewController, animated: true, completion: nil)
  }

  // MARK: - Customization

  fileprivate let whiteColor = UIColor(red: 0.941, green: 0.980, blue: 0.988, alpha: 1)
  fileprivate let redColor = UIColor(red: 0.988, green: 0.173, blue: 0.357, alpha: 1)
  fileprivate let blueColor = UIColor(red: 0.243, green: 0.769, blue: 0.831, alpha: 1)

  fileprivate func customizeTextTool() {
    let fonts = [
      Font(displayName: "Arial", fontName: "ArialMT", identifier: "Arial"),
      Font(displayName: "Helvetica", fontName: "Helvetica", identifier: "Helvetica"),
      Font(displayName: "Avenir", fontName: "Avenir-Heavy", identifier: "Avenir-Heavy"),
      Font(displayName: "Chalk", fontName: "Chalkduster", identifier: "Chalkduster"),
      Font(displayName: "Copperplate", fontName: "Copperplate", identifier: "Copperplate"),
      Font(displayName: "Noteworthy", fontName: "Noteworthy-Bold", identifier: "Notewortyh")
    ]

    FontImporter.all = fonts
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
      options.allowedCameraPositions = [.front]

      // Disable flash
      options.allowedFlashModes = [.off]
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

      options.actionButtonConfigurationClosure = { cell, _ in
        cell.contentTintColor = UIColor.red
      }
    }
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
