//
//  CameraViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 15/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation

/// A closure that allows the configuration of the given recording mode button.
/// The second parameter contains the state, the button represents.
public typealias RecordingModeButtonConfigurationClosure = (UIButton, RecordingMode) -> ()

/**
  Options for configuring a `CameraViewController`.
 */
@objc(IMGLYCameraViewControllerOptions) public class CameraViewControllerOptions: NSObject {

    /// The views background color. In video mode the colors alpha value is reduced to 0.3.
    /// Defaults to the global background color.
    public let backgroundColor: UIColor?

    /// Use this closure to configure the flash button.
    public let flashButtonConfigurationClosure: ButtonConfigurationClosure?

    /// Use this closure to configure the switch camera button.
    public let switchCameraButtonConfigurationClosure: ButtonConfigurationClosure?

    /// Use this closure to configure the camera roll button.
    public let cameraRollButtonConfigurationClosure: ButtonConfigurationClosure?

    /// Use this closure to configure the action button in photo mode.
    public let photoActionButtonConfigurationClosure: ButtonConfigurationClosure?

    /// Use this closure to configure the filter selector button.
    public let filterSelectorButtonConfigurationClosure: ButtonConfigurationClosure?

    /// Use this closure to configure the timelabel.
    public let timeLabelConfigurationClosure: LabelConfigurationClosure?

    // swiftlint:disable variable_name
    /// Use this closure to configure the filter intensity slider.
    public let filterIntensitySliderConfigurationClosure: SliderConfigurationClosure?
    // swiftlint:enable variable_name

    /// Use this closure to configure the given recording mode button. By default the buttons
    /// light up in yellow, when selected.
    public let recordingModeButtonConfigurationClosure: RecordingModeButtonConfigurationClosure?

    /// Enable/Disable permanent crop to square. Disabled by default.
    public let cropToSquare: Bool

    /// The maximum length of a video. If set to 0 the length is unlimited.
    public let maximumVideoLength: Int

    /// Enable/Disable tap to focus on the camera preview image. Enabled by default.
    public let tapToFocusEnabled: Bool

    /// Show/Hide the camera roll button. Enabled by default.
    public let showCameraRoll: Bool

    /// Enable/Disable filter bottom drawer. Enabled by default.
    public let showFilters: Bool

    /// An object conforming to the `FiltersDataSourceProtocol`
    public let filtersDataSource: FiltersDataSourceProtocol

    /// Enable/Disable filter intensity slider.
    public let showFilterIntensitySlider: Bool

    /// Allowed camera positions. Defaults to all available positions
    /// and falls back to supported position if only one exists.
    public let allowedCameraPositions: [AVCaptureDevicePosition]

    /// Allowed flash modes. Defaults to all available modes. Duplicate
    /// values are not removed and may lead to unexpected behaviour. The
    /// first option is selected on launch, although the view controller
    /// tries to match the previous torch mode on record mode changes.
    public let allowedFlashModes: [AVCaptureFlashMode]

    /// Allowed torch modes. Defaults to all available modes. Duplicate
    /// values are not removed and may lead to unexpected behaviour. The
    /// first option is selected on launch, although the view controller
    /// tries to match the previous flash mode on record mode changes.
    public let allowedTorchModes: [AVCaptureTorchMode]

    /// Supported recording modes (e.g. .Photo or .Video). Defaults to all available modes.
    /// Duplicate values are not removed and may lead to unexpected behaviour. The first option is
    /// selected on launch. To set this option from Obj-C see `allowedRecordingModesAsNSNumbers`.
    public let allowedRecordingModes: [RecordingMode]

    /**
     Returns a newly allocated instance of a `CameraViewControllerOptions` using the default builder.

     - returns: An instance of a `CameraViewControllerOptions`.
     */
    convenience override init() {
        self.init(builder: CameraViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `CameraViewControllerOptions` using the given builder.

     - parameter builder: A `CameraViewControllerOptionsBuilder` instance.

     - returns: An instance of a `CameraViewControllerOptions`.
     */
    init(builder: CameraViewControllerOptionsBuilder) {
        backgroundColor = builder.backgroundColor
        flashButtonConfigurationClosure = builder.flashButtonConfigurationClosure
        switchCameraButtonConfigurationClosure = builder.switchCameraButtonConfigurationClosure
        cameraRollButtonConfigurationClosure = builder.cameraRollButtonConfigurationClosure
        photoActionButtonConfigurationClosure = builder.photoActionButtonConfigurationClosure
        filterSelectorButtonConfigurationClosure = builder.filterSelectorButtonConfigurationClosure
        recordingModeButtonConfigurationClosure = builder.recordingModeButtonConfigurationClosure
        timeLabelConfigurationClosure = builder.timeLabelConfigurationClosure
        filterIntensitySliderConfigurationClosure = builder.filterIntensitySliderConfigurationClosure
        cropToSquare = builder.cropToSquare
        maximumVideoLength = builder.maximumVideoLength
        tapToFocusEnabled = builder.tapToFocusEnabled
        showCameraRoll = builder.showCameraRoll
        showFilters = builder.showFilters
        filtersDataSource = builder.filtersDataSource
        showFilterIntensitySlider = builder.showFilterIntensitySlider
        allowedCameraPositions = builder.allowedCameraPositions
        allowedFlashModes = builder.allowedFlashModes
        allowedTorchModes = builder.allowedTorchModes
        allowedRecordingModes = builder.allowedRecordingModes.count > 0 ? builder.allowedRecordingModes : [.Photo, .Video]
        super.init()
    }
}

/**
   The default `IMGLYCameraViewControllerOptionsBuilder` for `IMGLYCameraViewControllerOptions`.
 */
@objc(IMGLYCameraViewControllerOptionsBuilder) public class CameraViewControllerOptionsBuilder: NSObject {

    /// The views background color. In video mode the colors alpha value is reduced to 0.3.
    /// Defaults to the global background color.
    public var backgroundColor: UIColor?

    /// Use this closure to configure the flash button. Defaults to an empty implementation.
    public var flashButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /// Use this closure to configure the switch camera button. Defaults to an empty implementation.
    public var switchCameraButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /// Use this closure to configure the camera roll button. Defaults to an empty implementation.
    public var cameraRollButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /// Use this closure to configure the action button in photo mode. Defaults to an empty implementation.
    public var photoActionButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /// Use this closure to configure the filter selector button. Defaults to an empty implementation.
    public var filterSelectorButtonConfigurationClosure: ButtonConfigurationClosure? = nil

    /// Use this closure to configure the timelabel. Defaults to an empty implementation.
    public var timeLabelConfigurationClosure: LabelConfigurationClosure? = nil

    // swiftlint:disable variable_name
    /// Use this closure to configure the filter intensity slider. Defaults to an empty implementation.
    public var filterIntensitySliderConfigurationClosure: SliderConfigurationClosure? = nil
    // swiftlint:enable variable_name

    /// Use this closure to configure the given recording mode button. By default the buttons
    /// light up in yellow, when selected.
    public var recordingModeButtonConfigurationClosure: RecordingModeButtonConfigurationClosure? = nil

    /// Enable/Disable permanent crop to square. Disabled by default.
    public var cropToSquare = false

    /// The maximum length of a video. If set to 0 the length is unlimited.
    public var maximumVideoLength = 0

    /// Enable/Disable tap to focus on the camera preview image. Enabled by default.
    public var tapToFocusEnabled = true

    /// Show/Hide the camera roll button. Enabled by default.
    public var showCameraRoll = true

    /// Enable/Disable filter bottom drawer. Enabled by default.
    public var showFilters = true

    /// An object conforming to the `FiltersDataSourceProtocol`
    public var filtersDataSource: FiltersDataSourceProtocol = FiltersDataSource()

    /// Enable/Disable filter intensity slider.
    public var showFilterIntensitySlider = true

    /// Allowed camera positions. Defaults to all available positions
    /// and falls back to supported position if only one exists. To set
    /// this option from Obj-C see `allowedCameraPositionsAsNSNumbers`.
    public var allowedCameraPositions: [AVCaptureDevicePosition] = [ .Back, .Front ]

    /// Allowed flash modes. Defaults to all available modes. Duplicate
    /// values are not removed and may lead to unexpected behaviour. The
    /// first option is selected on launch, although the view controller
    /// tries to match the previous torch mode on record mode changes.
    /// To set this option from Obj-C see `allowedFlashModesAsNSNumbers`.
    public var allowedFlashModes: [AVCaptureFlashMode] = [ .Auto, .On, .Off ]

    /// Allowed torch modes. Defaults to all available modes. Duplicate
    /// values are not removed and may lead to unexpected behaviour. The
    /// first option is selected on launch, although the view controller
    /// tries to match the previous flash mode on record mode changes.
    /// To set this option from Obj-C see `allowedTorchModesAsNSNumbers`.
    public var allowedTorchModes: [AVCaptureTorchMode] = [ .Auto, .On, .Off ]

    /// Supported recording modes (e.g. .Photo or .Video). Defaults to all available modes.
    /// Duplicate values are not removed and may lead to unexpected behaviour. The first option is
    /// selected on launch. To set this option from Obj-C see `allowedRecordingModesAsNSNumbers`.
    public var allowedRecordingModes: [RecordingMode] = [ .Photo, .Video ]

    /// An array of `AVCaptureDevicePosition` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedCameraPositions` with the corresponding unwrapped values.
    public var allowedCameraPositionsAsNSNumbers: [NSNumber] {
        get {
            return allowedCameraPositions.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedCameraPositions = newValue.flatMap { AVCaptureDevicePosition(rawValue: $0.integerValue) }
        }
    }

    /// An array of `AVCaptureFlashMode` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedFlashModes` with the corresponding unwrapped values.
    public var allowedFlashModesAsNSNumbers: [NSNumber] {
        get {
            return allowedFlashModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedFlashModes = newValue.flatMap { AVCaptureFlashMode(rawValue: $0.integerValue) }
        }
    }

    /// An array of `AVCaptureTorchMode` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedFlashModes` with the corresponding unwrapped values.
    public var allowedTorchModesAsNSNumbers: [NSNumber] {
        get {
            return allowedTorchModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedTorchModes = newValue.flatMap { AVCaptureTorchMode(rawValue: $0.integerValue) }
        }
    }

    /// An array of `RecordingMode` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedRecordingModes` with the corresponding unwrapped values.
    public var allowedRecordingModesAsNSNumbers: [NSNumber] {
        get {
            return allowedRecordingModes.map { NSNumber(integer: $0.rawValue) }
        }

        set {
            allowedRecordingModes = newValue.flatMap { RecordingMode(rawValue: $0.integerValue) }
        }
    }
}
