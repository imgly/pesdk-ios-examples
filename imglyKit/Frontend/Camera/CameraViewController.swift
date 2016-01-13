//
//  CameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

private let kShowFilterIntensitySliderInterval = NSTimeInterval(2)
private let kFilterSelectionViewHeight = 100
private let kBottomControlSize = CGSize(width: 47, height: 47)
public typealias CameraCompletionBlock = (UIImage?, NSURL?) -> (Void)

/// A closure that allows the configuration of the given recording mode button.
/// The second parameter contains the state, the button represents.
public typealias RecordingModeButtonConfigurationClosure = (UIButton, RecordingMode) -> ()

@objc(IMGLYCameraViewControllerOptions) public class CameraViewControllerOptions: NSObject {

    /// The views background color. In video mode the colors alpha value is reduced to 0.3.
    /// Defaults to the global background color.
    public let backgroundColor: UIColor?

    /// Use this closure to configure the flash button. Defaults to an empty implementation.
    public let flashButtonConfigurationClosure: ButtonConfigurationClosure

    /// Use this closure to configure the switch camera button. Defaults to an empty implementation.
    public let switchCameraButtonConfigurationClosure: ButtonConfigurationClosure

    /// Use this closure to configure the camera roll button. Defaults to an empty implementation.
    public let cameraRollButtonConfigurationClosure: ButtonConfigurationClosure

    /// Use this closure to configure the action button in photo mode. Defaults to an empty implementation.
    public let photoActionButtonConfigurationClosure: ButtonConfigurationClosure

    /// Use this closure to configure the filter selector button. Defaults to an empty implementation.
    public let filterSelectorButtonConfigurationClosure: ButtonConfigurationClosure

    /// Use this closure to configure the timelabel. Defaults to an empty implementation.
    public let timeLabelConfigurationClosure: LabelConfigurationClosure

    // swiftlint:disable variable_name_max_length
    /// Use this closure to configure the filter intensity slider. Defaults to an empty implementation.
    public let filterIntensitySliderConfigurationClosure: SliderConfigurationClosure
    // swiftlint:enable variable_name_max_length

    /// Use this closure to configure the given recording mode button. By default the buttons
    /// light up in yellow, when selected.
    public let recordingModeButtonConfigurationClosure: RecordingModeButtonConfigurationClosure

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

    convenience override init() {
        self.init(builder: CameraViewControllerOptionsBuilder())
    }

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

@objc(IMGLYCameraViewControllerOptionsBuilder) public class CameraViewControllerOptionsBuilder: NSObject {

    /// The views background color. In video mode the colors alpha value is reduced to 0.3.
    /// Defaults to the global background color.
    public var backgroundColor: UIColor?

    /// Use this closure to configure the flash button. Defaults to an empty implementation.
    public lazy var flashButtonConfigurationClosure: ButtonConfigurationClosure = { _ in }

    /// Use this closure to configure the switch camera button. Defaults to an empty implementation.
    public lazy var switchCameraButtonConfigurationClosure: ButtonConfigurationClosure = { _ in }

    /// Use this closure to configure the camera roll button. Defaults to an empty implementation.
    public lazy var cameraRollButtonConfigurationClosure: ButtonConfigurationClosure = { _ in }

    /// Use this closure to configure the action button in photo mode. Defaults to an empty implementation.
    public lazy var photoActionButtonConfigurationClosure: ButtonConfigurationClosure = { _ in }

    /// Use this closure to configure the filter selector button. Defaults to an empty implementation.
    public lazy var filterSelectorButtonConfigurationClosure: ButtonConfigurationClosure = { _ in }

    /// Use this closure to configure the timelabel. Defaults to an empty implementation.
    public lazy var timeLabelConfigurationClosure: LabelConfigurationClosure = { _ in }

    // swiftlint:disable variable_name_max_length
    /// Use this closure to configure the filter intensity slider. Defaults to an empty implementation.
    public lazy var filterIntensitySliderConfigurationClosure: SliderConfigurationClosure = { _ in }
    // swiftlint:enable variable_name_max_length

    /// Use this closure to configure the given recording mode button. By default the buttons
    /// light up in yellow, when selected.
    public lazy var recordingModeButtonConfigurationClosure: RecordingModeButtonConfigurationClosure = { _ in }

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


@objc(IMGLYCameraViewController) public class CameraViewController: UIViewController {

    private let configuration: Configuration

    private var options: CameraViewControllerOptions {
        return self.configuration.cameraViewControllerOptions
    }

    private var currentBackgroundColor: UIColor {
        get {
            if let customBackgroundColor = options.backgroundColor {
                return customBackgroundColor
            }

            return configuration.backgroundColor
        }
    }

    // MARK: - Initializers

     /**
     Initializes a camera view controller using the given parameters.

     - parameter configuration:  An `Configuration` object.

     - returns: And initialized `CameraViewController`.

     - discussion: If you use the standard `init` method or `initWithCoder` to initialize a `CameraViewController` object, a camera view controller with all supported recording modes and the default configuration is created.
     */
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.configuration = Configuration()
        super.init(coder: aDecoder)
    }

    // MARK: - Properties

    public private(set) lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = self.currentBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public private(set) lazy var topControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = self.currentBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public private(set) lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = self.currentBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    public private(set) lazy var bottomControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = self.currentBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var flashButton: UIButton = {
        let bundle = NSBundle(forClass: CameraViewController.self)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setImage(buttonImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.contentHorizontalAlignment = .Left
        button.addTarget(self, action: "changeFlash:", forControlEvents: .TouchUpInside)
        button.hidden = true
        self.options.flashButtonConfigurationClosure(button)
        return button
    }()

    private lazy var switchCameraButton: UIButton = {
        let bundle = NSBundle(forClass: CameraViewController.self)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "cam_switch", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setImage(buttonImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.contentHorizontalAlignment = .Right
        button.addTarget(self, action: "switchCamera:", forControlEvents: .TouchUpInside)
        button.hidden = true
        self.options.switchCameraButtonConfigurationClosure(button)
        return button
    }()

    private lazy var cameraRollButton: UIButton = {
        let bundle = NSBundle(forClass: CameraViewController.self)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.imageView?.contentMode = .ScaleAspectFill
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "showCameraRoll:", forControlEvents: .TouchUpInside)
        self.options.cameraRollButtonConfigurationClosure(button)
        return button
    }()

    public private(set) lazy var actionButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public private(set) lazy var recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        label.textColor = UIColor.whiteColor()
        label.text = "00:00"
        self.options.timeLabelConfigurationClosure(label)
        return label
    }()

    public private(set) var actionButton: UIControl?

    public private(set) lazy var filterSelectionButton: UIButton = {
        let bundle = NSBundle(forClass: CameraViewController.self)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "show_filter", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "toggleFilters:", forControlEvents: .TouchUpInside)
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.options.filterSelectorButtonConfigurationClosure(button)
        return button
    }()

    public private(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = NSBundle(forClass: CameraViewController.self)
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.75
        slider.alpha = 0
        slider.addTarget(self, action: "changeIntensity:", forControlEvents: .ValueChanged)

        slider.minimumTrackTintColor = UIColor.whiteColor()
        slider.maximumTrackTintColor = UIColor.whiteColor()
        slider.thumbTintColor = UIColor(red:1, green:0.8, blue:0, alpha:1)
        let sliderThumbImage = UIImage(named: "slider_thumb_image", inBundle: bundle, compatibleWithTraitCollection: nil)
        slider.setThumbImage(sliderThumbImage, forState: .Normal)
        slider.setThumbImage(sliderThumbImage, forState: .Highlighted)

        slider.hidden = !self.options.showFilterIntensitySlider
        self.options.filterIntensitySliderConfigurationClosure(slider)

        return slider
    }()

    public private(set) lazy var swipeRightGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: "toggleMode:")
        return recognizer
    }()

    public private(set) lazy var swipeLeftGestureRecognizer: UISwipeGestureRecognizer = {
        let recognizer = UISwipeGestureRecognizer(target: self, action: "toggleMode:")
        recognizer.direction = .Left
        return recognizer
    }()

    private var recordingModeSelectionButtons = [UIButton]()

    private var hideSliderTimer: NSTimer?

    private var filterSelectionViewConstraint: NSLayoutConstraint?
    public let filterSelectionController = FilterSelectionController()

    public private(set) var cameraController: CameraController?

    private var buttonsEnabled = true {
        didSet {
            flashButton.enabled = buttonsEnabled
            switchCameraButton.enabled = buttonsEnabled
            cameraRollButton.enabled = buttonsEnabled
            actionButtonContainer.userInteractionEnabled = buttonsEnabled

            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.enabled = buttonsEnabled
            }

            swipeRightGestureRecognizer.enabled = buttonsEnabled
            swipeLeftGestureRecognizer.enabled = buttonsEnabled
            filterSelectionController.view.userInteractionEnabled = buttonsEnabled
            filterSelectionButton.enabled = buttonsEnabled
        }
    }

    public var completionBlock: CameraCompletionBlock?

    private var centerModeButtonConstraint: NSLayoutConstraint?
    private var cameraPreviewContainerTopConstraint: NSLayoutConstraint?
    private var cameraPreviewContainerBottomConstraint: NSLayoutConstraint?

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

//        configureRecordingModeSwitching()
        configureViewHierarchy()
        configureViewConstraints()
        configureFilterSelectionController()
        configureCameraController()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.beginAppearanceTransition(true, animated: animated)
        }
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.endAppearanceTransition()
        }

        setLastImageFromRollAsPreview()
        cameraController?.startCamera()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraController?.stopCamera()

        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.beginAppearanceTransition(false, animated: animated)
        }
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
            filterSelectionController.endAppearanceTransition()
        }
    }

    public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return false
    }

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    public override func prefersStatusBarHidden() -> Bool {
        return true
    }

    public override func shouldAutorotate() -> Bool {
        return false
    }

    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }

    // MARK: - Configuration

    private func configureRecordingModeSwitching() {
        if configuration.cameraViewControllerOptions.allowedRecordingModes.count > 1 {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)

            recordingModeSelectionButtons = configuration.cameraViewControllerOptions.allowedRecordingModes.map { $0.selectionButton }

            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.addTarget(self, action: "toggleMode:", forControlEvents: .TouchUpInside)
            }
        }
    }

    private func configureViewHierarchy() {
        /// Handle custom colors
        view.backgroundColor = currentBackgroundColor

        view.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(cameraPreviewContainer)
        view.addSubview(topControlsView)
        view.addSubview(bottomControlsView)

        addChildViewController(filterSelectionController)
        filterSelectionController.didMoveToParentViewController(self)
        view.addSubview(filterSelectionController.view)

        topControlsView.addSubview(flashButton)

        topControlsView.addSubview(switchCameraButton)

        bottomControlsView.addSubview(actionButtonContainer)

        if options.showCameraRoll {
            bottomControlsView.addSubview(cameraRollButton)
        }

        if options.showFilters {
            bottomControlsView.addSubview(filterSelectionButton)
        }

        for recordingModeSelectionButton in recordingModeSelectionButtons {
            bottomControlsView.addSubview(recordingModeSelectionButton)
            options.recordingModeButtonConfigurationClosure(recordingModeSelectionButton, configuration.cameraViewControllerOptions.allowedRecordingModes[recordingModeSelectionButtons.indexOf(recordingModeSelectionButton)!])
        }

        backgroundContainerView.addSubview(filterIntensitySlider)
    }

    private func configureViewConstraints() {
        let views: [String : AnyObject] = [
            "backgroundContainerView" : backgroundContainerView,
            "topLayoutGuide" : topLayoutGuide,
            "topControlsView" : topControlsView,
            "cameraPreviewContainer" : cameraPreviewContainer,
            "bottomControlsView" : bottomControlsView,
            "filterSelectionView" : filterSelectionController.view,
            "flashButton" : flashButton,
            "switchCameraButton" : switchCameraButton,
            "cameraRollButton" : cameraRollButton,
            "actionButtonContainer" : actionButtonContainer,
            "filterSelectionButton" : filterSelectionButton,
            "filterIntensitySlider" : filterIntensitySlider
        ]

        let metrics: [String : AnyObject] = [
            "topControlsViewHeight" : 44,
            "filterSelectionViewHeight" : kFilterSelectionViewHeight,
            "topControlMargin" : 20,
            "topControlMinWidth" : 44,
            "filterIntensitySliderLeftRightMargin" : 10
        ]

        configureSuperviewConstraintsWithMetrics(metrics, views: views)
        configureTopControlsConstraintsWithMetrics(metrics, views: views)
        configureBottomControlsConstraintsWithMetrics(metrics, views: views)
    }

    private func configureSuperviewConstraintsWithMetrics(metrics: [String : AnyObject], views: [String : AnyObject]) {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[backgroundContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundContainerView]|", options: [], metrics: nil, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[topControlsView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[cameraPreviewContainer]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomControlsView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: [], metrics: metrics, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][topControlsView(==topControlsViewHeight)]", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomControlsView][filterSelectionView(==filterSelectionViewHeight)]", options: [], metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .Bottom, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Top, multiplier: 1, constant: -20))

        cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topControlsView, attribute: .Bottom, multiplier: 1, constant: 0)
        cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraints([cameraPreviewContainerTopConstraint!, cameraPreviewContainerBottomConstraint!])

        filterSelectionViewConstraint = NSLayoutConstraint(item: filterSelectionController.view, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(filterSelectionViewConstraint!)
    }

    private func configureTopControlsConstraintsWithMetrics(metrics: [String : AnyObject], views: [String : AnyObject]) {
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==topControlMargin)-[flashButton(>=topControlMinWidth)]-(>=topControlMargin)-[switchCameraButton(>=topControlMinWidth)]-(==topControlMargin)-|", options: [], metrics: metrics, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flashButton]|", options: [], metrics: nil, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton]|", options: [], metrics: nil, views: views))
    }

    private func configureBottomControlsConstraintsWithMetrics(metrics: [String : AnyObject], views: [String : AnyObject]) {
        if recordingModeSelectionButtons.count > 0 {
            // Mode Buttons
            for i in 0 ..< recordingModeSelectionButtons.count - 1 {
                let leftButton = recordingModeSelectionButtons[i]
                let rightButton = recordingModeSelectionButtons[i + 1]

                bottomControlsView.addConstraint(NSLayoutConstraint(item: leftButton, attribute: .Right, relatedBy: .Equal, toItem: rightButton, attribute: .Left, multiplier: 1, constant: -20))
                bottomControlsView.addConstraint(NSLayoutConstraint(item: leftButton, attribute: .Baseline, relatedBy: .Equal, toItem: rightButton, attribute: .Baseline, multiplier: 1, constant: 0))
            }

            centerModeButtonConstraint = NSLayoutConstraint(item: recordingModeSelectionButtons[0], attribute: .CenterX, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0)
            bottomControlsView.addConstraint(centerModeButtonConstraint!)
            bottomControlsView.addConstraint(NSLayoutConstraint(item: recordingModeSelectionButtons[0], attribute: .Bottom, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .Top, multiplier: 1, constant: -5))
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Top, relatedBy: .Equal, toItem: recordingModeSelectionButtons[0], attribute: .Top, multiplier: 1, constant: -5))
        } else {
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Top, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .Top, multiplier: 1, constant: -5))
        }

        // CameraRollButton
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: kBottomControlSize.width))
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: kBottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .CenterY, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Left, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Left, multiplier: 1, constant: 20))

        // ActionButtonContainer
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70))
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .CenterX, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Bottom, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .Bottom, multiplier: 1, constant: 10))

        // FilterSelectionButton
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: kBottomControlSize.width))
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: kBottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Right, relatedBy: .Equal, toItem: filterSelectionButton, attribute: .Right, multiplier: 1, constant: 20))
    }

    private func configureCameraController() {
        let cameraController = CameraController()
        cameraController.recordingModes = configuration.cameraViewControllerOptions.allowedRecordingModes
        cameraController.cameraPositions = configuration.cameraViewControllerOptions.allowedCameraPositions
        cameraController.flashModes = configuration.cameraViewControllerOptions.allowedFlashModes
        cameraController.torchModes = configuration.cameraViewControllerOptions.allowedTorchModes

        // Handlers
        cameraController.availableCameraPositionsChangedHandler = { [weak self] in
            if cameraController.cameraPositions.count > 1 {
                self?.switchCameraButton.hidden = false
            } else {
                self?.switchCameraButton.hidden = true
            }
        }

        cameraController.flashChangedHandler = { [weak self] hasFlash, flashMode, flashAvailable in
            self?.flashButton.hidden = !hasFlash
            self?.flashButton.enabled = flashAvailable

            let bundle = NSBundle(forClass: CameraViewController.self)

            switch flashMode {
            case .Auto:
                self?.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .On:
                self?.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .Off:
                self?.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            }
        }

//        cameraController.torchChangedHandler = { [weak self] hasTorch, torchMode, torchAvailable in
//            self?.flashButton.hidden = !hasTorch
//            self?.flashButton.enabled = torchAvailable
//
//            let bundle = NSBundle(forClass: CameraViewController.self)
//
//            switch torchMode {
//            case .Auto:
//                self?.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
//            case .On:
//                self?.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
//            case .Off:
//                self?.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
//            }
//        }

        do {
            try cameraController.setup()
        } catch CameraControllerError.MultipleCallsToSetup {
            fatalError("setup() on CameraController has been called before.")
        } catch CameraControllerError.UnableToInitializeCaptureDevice {
            print("No camera found on device")
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            fatalError("Unknown error")
        }

        cameraPreviewContainer.addSubview(cameraController.videoPreviewView)
        cameraController.videoPreviewView.frame = cameraPreviewContainer.bounds
        self.cameraController = cameraController

//        cameraController = CameraController(previewView: cameraPreviewContainer)
//        cameraController!.tapToFocusEnabled = options.tapToFocusEnabled
//        cameraController!.allowedCameraPositions = options.allowedCameraPositions
//        cameraController!.allowedFlashModes = options.allowedFlashModes
//        cameraController!.allowedTorchModes = options.allowedTorchModes
//        cameraController!.squareMode = options.cropToSquare
//
//        if options.maximumVideoLength > 0 {
//            cameraController!.maximumVideoLength = options.maximumVideoLength
//        }
//
//        cameraController!.delegate = self
//        cameraController!.setupWithInitialRecordingMode(currentRecordingMode)
    }

    private func configureFilterSelectionController() {
        filterSelectionController.dataSource = self.options.filtersDataSource
        filterSelectionController.selectedBlock = { [weak self] filterType, initialFilterIntensity in
//            if let cameraController = self?.cameraController where cameraController.effectFilter.filterType != filterType {
//                cameraController.effectFilter = InstanceFactory.effectFilterWithType(filterType)
//                cameraController.effectFilter.inputIntensity = initialFilterIntensity
//                self?.filterIntensitySlider.value = initialFilterIntensity
//            }

            if filterType == .None {
                self?.hideSliderTimer?.invalidate()
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha > 0 {
                    UIView.animateWithDuration(0.25) {
                        filterIntensitySlider.alpha = 0
                    }
                }
            } else {
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha < 1 {
                    UIView.animateWithDuration(0.25) {
                        filterIntensitySlider.alpha = 1
                    }
                }

                self?.resetHideSliderTimer()
            }
        }

//        filterSelectionController.activeFilterType = { [weak self] in
//            if let cameraController = self?.cameraController {
//                return cameraController.effectFilter.filterType
//            } else {
//                return .None
//            }
//        }
    }

    // MARK: - Helpers

    private func updateRecordingTimeLabel(seconds: Int) {
        self.recordingTimeLabel.text = NSString(format: "%02d:%02d", seconds / 60, seconds % 60) as String
    }

    private func addRecordingTimeLabel() {
        updateRecordingTimeLabel(options.maximumVideoLength)
        topControlsView.addSubview(recordingTimeLabel)

        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: topControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: topControlsView, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    private func updateConstraintsForRecordingMode(recordingMode: RecordingMode) {
        if let cameraPreviewContainerTopConstraint = cameraPreviewContainerTopConstraint {
            view.removeConstraint(cameraPreviewContainerTopConstraint)
        }

        if let cameraPreviewContainerBottomConstraint = cameraPreviewContainerBottomConstraint {
            view.removeConstraint(cameraPreviewContainerBottomConstraint)
        }


        switch recordingMode {
        case .Photo:
            cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topControlsView, attribute: .Bottom, multiplier: 1, constant: 0)
            cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Top, multiplier: 1, constant: 0)
        case .Video:
            cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
            cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
        }

        view.addConstraints([cameraPreviewContainerTopConstraint!, cameraPreviewContainerBottomConstraint!])
    }

    private func updateViewsForRecordingMode(recordingMode: RecordingMode) {
        let color: UIColor

        switch recordingMode {
        case .Photo:
            color = currentBackgroundColor
        case .Video:
            color = currentBackgroundColor.colorWithAlphaComponent(0.3)
        }

        topControlsView.backgroundColor = color
        bottomControlsView.backgroundColor = color
        filterSelectionController.collectionView?.backgroundColor = color
    }

    private func addActionButtonToContainer(actionButton: UIControl) {
        actionButtonContainer.addSubview(actionButton)
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionButton]|", options: [], metrics: nil, views: [ "actionButton" : actionButton ]))
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[actionButton]|", options: [], metrics: nil, views: [ "actionButton" : actionButton ]))
    }

    private func resetHideSliderTimer() {
        hideSliderTimer?.invalidate()
        hideSliderTimer = NSTimer.scheduledTimerWithTimeInterval(kShowFilterIntensitySliderInterval, target: self, selector: "hideFilterIntensitySlider:", userInfo: nil, repeats: false)
    }

    private func showEditorNavigationControllerWithImage(image: UIImage) {
        // swiftlint:disable force_cast
        let editorViewController = self.configuration.getClassForReplacedClass(MainEditorViewController.self).init() as! MainEditorViewController
        // swiftlint:enable force_cast
        editorViewController.configuration = configuration
        editorViewController.highResolutionImage = image
        if let cameraController = cameraController {
//            editorViewController.initialFilterType = cameraController.effectFilter.filterType
//            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
        }
        editorViewController.completionBlock = editorCompletionBlock

        let navigationController = NavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = false

        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    private func saveMovieWithMovieURLToAssets(movieURL: NSURL) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(movieURL)
            }) { success, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        let bundle = NSBundle(forClass: CameraViewController.self)

                        let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.error-saving-video.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.error-saving-video.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Cancel, handler: nil)

                        alertController.addAction(cancelAction)

                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }

                do {
                    try NSFileManager.defaultManager().removeItemAtURL(movieURL)
                } catch _ {
                }
        }
    }

    public func setLastImageFromRollAsPreview() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject as? PHAsset {
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: CGSize(width: kBottomControlSize.width * 2, height: kBottomControlSize.height * 2), contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.cameraRollButton.setImage(result, forState: UIControlState.Normal)
            }
        }
    }

    // MARK: - Targets

    @objc private func toggleMode(sender: AnyObject?) {
//        let recordingModes = configuration.cameraViewControllerOptions.allowedRecordingModes
//
//        if let gestureRecognizer = sender as? UISwipeGestureRecognizer {
//            if gestureRecognizer.direction == .Left {
//                let currentIndex = recordingModes.indexOf(currentRecordingMode)
//
//                if let currentIndex = currentIndex where currentIndex < recordingModes.count - 1 {
//                    currentRecordingMode = recordingModes[currentIndex + 1]
//                    return
//                }
//            } else if gestureRecognizer.direction == .Right {
//                let currentIndex = recordingModes.indexOf(currentRecordingMode)
//
//                if let currentIndex = currentIndex where currentIndex > 0 {
//                    currentRecordingMode = recordingModes[currentIndex - 1]
//                    return
//                }
//            }
//        }
//
//        if let button = sender as? UIButton {
//            let buttonIndex = recordingModeSelectionButtons.indexOf(button)
//
//            if let buttonIndex = buttonIndex {
//                currentRecordingMode = recordingModes[buttonIndex]
//                return
//            }
//        }
    }

    @objc private func hideFilterIntensitySlider(timer: NSTimer?) {
        UIView.animateWithDuration(0.25) {
            self.filterIntensitySlider.alpha = 0
            self.hideSliderTimer = nil
        }
    }

    public func changeFlash(sender: UIButton?) {
//        switch currentRecordingMode {
//        case .Photo:
            cameraController?.selectNextFlashMode()
//        case .Video:
//            cameraController?.selectNextTorchMode()
//        }
    }

    public func switchCamera(sender: UIButton?) {
        cameraController?.toggleCameraPosition()
    }

    public func showCameraRoll(sender: UIButton?) {
        let imagePicker = UIImagePickerController()

        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [String(kUTTypeImage)]
        imagePicker.allowsEditing = false

        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    public func takePhoto(sender: UIButton?) {
//        cameraController?.takePhoto { image, error in
//            if error == nil {
//                dispatch_async(dispatch_get_main_queue()) {
//                    if let completionBlock = self.completionBlock {
//                        completionBlock(image, nil)
//                    } else {
//                        if let image = image {
//                            self.showEditorNavigationControllerWithImage(image)
//                        }
//                    }
//                }
//            }
//        }
    }

    public func recordVideo(sender: VideoRecordButton?) {
//        if let recordVideoButton = sender {
//            if recordVideoButton.recording {
//                cameraController?.startVideoRecording()
//            } else {
//                cameraController?.stopVideoRecording()
//            }
//
//            if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
//                toggleFilters(filterSelectionButton)
//            }
//        }
    }

    public func toggleFilters(sender: UIButton?) {
        if let filterSelectionViewConstraint = self.filterSelectionViewConstraint {
            let animationDuration = NSTimeInterval(0.6)
            let dampingFactor = CGFloat(0.6)

            if filterSelectionViewConstraint.constant == 0 {
                // Expand
                filterSelectionController.beginAppearanceTransition(true, animated: true)
                filterSelectionViewConstraint.constant = -1 * CGFloat(kFilterSelectionViewHeight)
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: [], animations: {
                    sender?.transform = CGAffineTransformIdentity
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        self.filterSelectionController.endAppearanceTransition()
                })
            } else {
                // Close
                filterSelectionController.beginAppearanceTransition(false, animated: true)
                filterSelectionViewConstraint.constant = 0
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: [], animations: {
                    sender?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        self.filterSelectionController.endAppearanceTransition()
                })
            }
        }
    }

    @objc private func changeIntensity(sender: UISlider?) {
        if let slider = sender {
            resetHideSliderTimer()
//            cameraController?.effectFilter.inputIntensity = slider.value
        }
    }

    // MARK: - Completion

    private func editorCompletionBlock(result: EditorResult, image: UIImage?) {
        if let image = image where result == .Done {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo: UnsafePointer<Void>) {
        setLastImageFromRollAsPreview()
    }

}

//extension CameraViewController: CameraControllerDelegate {
//    public func cameraControllerDidStartCamera(cameraController: CameraController) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.buttonsEnabled = true
//        }
//    }
//
//    public func cameraControllerDidStopCamera(cameraController: CameraController) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.buttonsEnabled = false
//        }
//    }
//
//    public func cameraControllerDidStartStillImageCapture(cameraController: CameraController) {
//        dispatch_async(dispatch_get_main_queue()) {
//            // Animate the actionButton if it is a UIButton and has a sequence of images set
//            (self.actionButtonContainer.subviews.first as? UIButton)?.imageView?.startAnimating()
//            self.buttonsEnabled = false
//        }
//    }
//
//    public func cameraControllerDidFailAuthorization(cameraController: CameraController) {
//        dispatch_async(dispatch_get_main_queue()) {
//            let bundle = NSBundle(forClass: CameraViewController.self)
//
//            let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.camera-no-permission.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: NSLocalizedString("camera-view-controller.camera-no-permission.message", tableName: nil, bundle: bundle, value: "", comment: ""), preferredStyle: .Alert)
//
//            let settingsAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.settings", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Default) { _ in
//                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
//                    UIApplication.sharedApplication().openURL(url)
//                }
//            }
//
//            let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Cancel, handler: nil)
//
//            alertController.addAction(settingsAction)
//            alertController.addAction(cancelAction)
//
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
//    }
//
//
//    public func cameraController(cameraController: CameraController, willSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.buttonsEnabled = false
//        }
//    }
//
//    public func cameraController(cameraController: CameraController, didSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.buttonsEnabled = true
//            self.updateFlashButton()
//        }
//    }
//
//    public func cameraController(cameraController: CameraController, willSwitchToRecordingMode recordingMode: RecordingMode) {
//        buttonsEnabled = false
//
//        if let centerModeButtonConstraint = centerModeButtonConstraint {
//            bottomControlsView.removeConstraint(centerModeButtonConstraint)
//        }
//
//        // add new action button to container
//        let actionButton = currentRecordingMode.actionButton
//        actionButton.addTarget(self, action: currentRecordingMode.actionSelector, forControlEvents: .TouchUpInside)
//        actionButton.alpha = 0
//        self.addActionButtonToContainer(actionButton)
//        // Call configuration closure if actionButton is a UIButton subclass
//        if let imageCaptureActionButton = actionButton as? UIButton {
//            self.options.photoActionButtonConfigurationClosure(imageCaptureActionButton)
//        }
//        actionButton.layoutIfNeeded()
//
//        let buttonIndex = recordingModes.indexOf(currentRecordingMode)!
//        if recordingModeSelectionButtons.count >= buttonIndex + 1 {
//            let target = recordingModeSelectionButtons[buttonIndex]
//
//            // create new centerModeButtonConstraint
//            self.centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .CenterX, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0)
//            self.bottomControlsView.addConstraint(centerModeButtonConstraint!)
//        }
//
//        // add recordingTimeLabel
//        if recordingMode == .Video {
//            self.addRecordingTimeLabel()
//            self.cameraController?.hideSquareMask()
//        } else {
//            if options.cropToSquare {
//                self.cameraController?.showSquareMask()
//            }
//        }
//
//        self.view.bringSubviewToFront(self.filterIntensitySlider)
//    }
//
//    public func cameraController(cameraController: CameraController, didSwitchToRecordingMode recordingMode: RecordingMode) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.setLastImageFromRollAsPreview()
//            self.buttonsEnabled = true
//
//            if recordingMode == .Photo {
//                self.recordingTimeLabel.removeFromSuperview()
//            }
//        }
//    }
//
//    public func cameraControllerAnimateAlongsideFirstPhaseOfRecordingModeSwitchBlock(cameraController: CameraController) -> (() -> Void) {
//        return {
//            let buttonIndex = self.recordingModes.indexOf(self.currentRecordingMode)!
//            if self.recordingModeSelectionButtons.count >= buttonIndex + 1 {
//                let target = self.recordingModeSelectionButtons[buttonIndex]
//
//                // mark target as selected
//                target.selected = true
//
//                // deselect all other buttons
//                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
//                    if recordingModeSelectionButton != target {
//                        recordingModeSelectionButton.selected = false
//                    }
//                }
//            }
//
//            // fade new action button in and old action button out
//            let actionButton = self.actionButtonContainer.subviews.last as? UIControl
//
//            // fetch previous action button from container
//            let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
//            actionButton?.alpha = 1
//
//            if let previousActionButton = previousActionButton, actionButton = actionButton where previousActionButton != actionButton {
//                previousActionButton.alpha = 0
//            }
//
//            self.cameraRollButton.alpha = self.currentRecordingMode == .Video ? 0 : 1
//
//            self.bottomControlsView.layoutIfNeeded()
//        }
//    }
//
//    public func cameraControllerFirstPhaseOfRecordingModeSwitchAnimationCompletionBlock(cameraController: CameraController) -> (() -> Void) {
//        return {
//            if self.actionButtonContainer.subviews.count > 1 {
//                // fetch previous action button from container
//                let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
//
//                // remove old action button
//                previousActionButton?.removeFromSuperview()
//            }
//
//            self.updateConstraintsForRecordingMode(self.currentRecordingMode)
//        }
//    }
//
//    public func cameraControllerAnimateAlongsideSecondPhaseOfRecordingModeSwitchBlock(cameraController: CameraController) -> (() -> Void) {
//        return {
//            // update constraints for view hierarchy
//            self.updateViewsForRecordingMode(self.currentRecordingMode)
//
//            self.recordingTimeLabel.alpha = self.currentRecordingMode == .Video ? 1 : 0
//        }
//    }
//
//    public func cameraControllerDidStartRecording(cameraController: CameraController) {
//        dispatch_async(dispatch_get_main_queue()) {
//            UIView.animateWithDuration(0.25) {
//                self.swipeLeftGestureRecognizer.enabled = false
//                self.swipeRightGestureRecognizer.enabled = false
//
//                self.switchCameraButton.alpha = 0
//                self.filterSelectionButton.alpha = 0
//                self.bottomControlsView.backgroundColor = UIColor.clearColor()
//
//                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
//                    recordingModeSelectionButton.alpha = 0
//                }
//            }
//        }
//    }
//
//    private func updateUIForStoppedRecording() {
//        UIView.animateWithDuration(0.25) {
//            self.swipeLeftGestureRecognizer.enabled = true
//            self.swipeRightGestureRecognizer.enabled = true
//
//            self.switchCameraButton.alpha = 1
//            self.filterSelectionButton.alpha = 1
//            self.bottomControlsView.backgroundColor = self.currentBackgroundColor.colorWithAlphaComponent(0.3)
//
//            self.updateRecordingTimeLabel(self.options.maximumVideoLength)
//
//            for recordingModeSelectionButton in self.recordingModeSelectionButtons {
//                recordingModeSelectionButton.alpha = 1
//            }
//
//            if let actionButton = self.actionButtonContainer.subviews.first as? VideoRecordButton {
//                actionButton.recording = false
//            }
//        }
//    }
//
//    public func cameraControllerDidFailRecording(cameraController: CameraController, error: NSError?) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.updateUIForStoppedRecording()
//
//            let alertController = UIAlertController(title: "Error", message: "Video recording failed", preferredStyle: .Alert)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
//    }
//
//    public func cameraControllerDidFinishRecording(cameraController: CameraController, fileURL: NSURL) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.updateUIForStoppedRecording()
//            if let completionBlock = self.completionBlock {
//                completionBlock(nil, fileURL)
//            } else {
//                self.saveMovieWithMovieURLToAssets(fileURL)
//            }
//        }
//    }
//
//    public func cameraController(cameraController: CameraController, recordedSeconds seconds: Int) {
//        let displayedSeconds: Int
//
//        if options.maximumVideoLength > 0 {
//            displayedSeconds = options.maximumVideoLength - seconds
//        } else {
//            displayedSeconds = seconds
//        }
//
//        dispatch_async(dispatch_get_main_queue()) {
//            self.updateRecordingTimeLabel(displayedSeconds)
//        }
//    }
//}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage

        self.dismissViewControllerAnimated(true, completion: {
            if let completionBlock = self.completionBlock {
                completionBlock(image, nil)
            } else {
                if let image = image {
                    self.showEditorNavigationControllerWithImage(image)
                }
            }
        })
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
