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

private let kIndicatorSize = CGFloat(75)
private let kShowFilterIntensitySliderInterval = NSTimeInterval(2)
private let kFilterSelectionViewHeight = 100
private let kBottomControlSize = CGSize(width: 47, height: 47)
public typealias CameraCompletionBlock = (UIImage?, NSURL?) -> (Void)

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

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
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
        button.accessibilityLabel = Localize("Flash, automatic")
        button.accessibilityHint = Localize("Switch between flash modes")
        self.options.flashButtonConfigurationClosure?(button)
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
        button.accessibilityLabel = Localize("Camera chooser")
        button.accessibilityHint = Localize("Switch between the front and backfacing camera")
        self.options.switchCameraButtonConfigurationClosure?(button)
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
        button.accessibilityLabel = Localize("Photo Viewer")
        self.options.cameraRollButtonConfigurationClosure?(button)
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
        label.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently
        self.options.timeLabelConfigurationClosure?(label)
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
        button.accessibilityLabel = Localize("Filters")
        button.accessibilityHint = Localize("Show or hide the list of filters")
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.options.filterSelectorButtonConfigurationClosure?(button)
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
        slider.accessibilityLabel = Localize("Filter Intensity")
        slider.addTarget(self, action: "changeIntensity:", forControlEvents: .ValueChanged)

        slider.minimumTrackTintColor = UIColor.whiteColor()
        slider.maximumTrackTintColor = UIColor.whiteColor()
        slider.thumbTintColor = UIColor(red:1, green:0.8, blue:0, alpha:1)
        let sliderThumbImage = UIImage(named: "slider_thumb_image", inBundle: bundle, compatibleWithTraitCollection: nil)
        slider.setThumbImage(sliderThumbImage, forState: .Normal)
        slider.setThumbImage(sliderThumbImage, forState: .Highlighted)

        slider.hidden = !self.options.showFilterIntensitySlider
        self.options.filterIntensitySliderConfigurationClosure?(slider)

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

    private lazy var maskIndicatorLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1
        layer.frame = CGRect.zero
        layer.hidden = true
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return layer
    }()

    private lazy var upperMaskDarkenLayer: CALayer = {
        let layer = CALayer()
        layer.borderWidth = 0
        layer.frame = CGRect.zero
        layer.hidden = true
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.backgroundColor = UIColor(white: 0.0, alpha: 0.8).CGColor
        return layer
    }()

    private lazy var lowerMaskDarkenLayer: CALayer = {
        let layer = CALayer()
        layer.borderWidth = 0
        layer.frame = CGRect.zero
        layer.hidden = true
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.backgroundColor = UIColor(white: 0.0, alpha: 0.8).CGColor
        return layer
    }()

    private lazy var focusIndicatorLayer: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1
        layer.frame.size = CGSize(width: kIndicatorSize, height: kIndicatorSize)
        layer.hidden = true
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return layer
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

    private var snapshotView: UIView?
    private var cameraTransitionComplete: Bool?

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureRecordingModeSwitching()
        configureViewHierarchy()
        configureViewConstraints()
        configureViewsForInitialRecordingMode()
        configureFilterSelectionController()
        configureCameraController()
        configureMaskLayers()
        checkSDKVersionIfNeeded()
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
        if options.allowedRecordingModes.count > 1 {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)

            recordingModeSelectionButtons = options.allowedRecordingModes.map { $0.selectionButton }

            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.addTarget(self, action: "toggleMode:", forControlEvents: .TouchUpInside)
            }
        }
    }

    private func configureViewHierarchy() {
        // Handle custom colors
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
            options.recordingModeButtonConfigurationClosure?(recordingModeSelectionButton, options.allowedRecordingModes[recordingModeSelectionButtons.indexOf(recordingModeSelectionButton)!])
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

    private func configureViewsForInitialRecordingMode() {
        if recordingModeSelectionButtons.count >= 1 {
            recordingModeSelectionButtons[0].selected = true
        }

        let recordingMode = options.allowedRecordingModes[0]

        updateConstraintsForRecordingMode(recordingMode)
        updateViewsForRecordingMode(recordingMode)

        if recordingMode == .Photo && options.cropToSquare {
            showSquareMask()
        }

        // add new action button to container
        let actionButton = recordingMode.actionButton
        actionButton.addTarget(self, action: recordingMode.actionSelector, forControlEvents: .TouchUpInside)
        addActionButtonToContainer(actionButton)
    }

    private func configureCameraController() {
        let cameraController = CameraController()
        cameraController.cameraPositions = options.allowedCameraPositions
        cameraController.flashModes = options.allowedFlashModes
        cameraController.torchModes = options.allowedTorchModes

        // Handlers
        cameraController.runningStateChangedHandler = { [weak self] running in
            self?.buttonsEnabled = running
        }

        cameraController.cameraPositionChangedHandler = { [weak self] _, _ in
            self?.cameraTransitionComplete = true

            // Transition to the live preview. This only happens if the first phase of the animation is done.
            // Otherwise the animation itself takes care of transitioning to the live preview.
            self?.transitionFromSnapshotToLivePreviewAlongAnimations(nil)
            self?.buttonsEnabled = true
        }

        cameraController.availableCameraPositionsChangedHandler = { [weak self] in
            if cameraController.cameraPositions.count > 1 {
                self?.switchCameraButton.hidden = false
            } else {
                self?.switchCameraButton.hidden = true
            }
        }

        cameraController.recordingModeChangedHandler = { [weak self] previousRecordingMode, newRecordingMode in
            self?.cameraTransitionComplete = true

            // Transition to the live preview. This only happens if the first phase of the animation is done.
            // Otherwise the animation itself takes care of transitioning to the live preview.
            self?.transitionFromSnapshotToLivePreviewAlongAnimations {
                // update constraints for view hierarchy
                self?.updateViewsForRecordingMode(newRecordingMode)
                self?.recordingTimeLabel.alpha = newRecordingMode == .Video ? 1 : 0
            }

            self?.setLastImageFromRollAsPreview()
            self?.buttonsEnabled = true

            if newRecordingMode == .Photo {
                self?.recordingTimeLabel.removeFromSuperview()
            }

            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }

        cameraController.capturingStillImageHandler = { [weak self] capturing in
            if capturing {
                // Animate the actionButton if it is a UIButton and has a sequence of images set
                (self?.actionButtonContainer.subviews.first as? UIButton)?.imageView?.startAnimating()
                self?.buttonsEnabled = false
            }
        }

        cameraController.flashChangedHandler = { [weak self] hasFlash, flashMode, flashAvailable in
            self?.flashButton.hidden = !hasFlash
            self?.flashButton.enabled = flashAvailable

            let bundle = NSBundle(forClass: CameraViewController.self)

            switch flashMode {
            case .Auto:
                self?.flashButton.accessibilityLabel = Localize("Flash, automatic")
                self?.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .On:
                self?.flashButton.accessibilityLabel = Localize("Flash, on")
                self?.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .Off:
                self?.flashButton.accessibilityLabel = Localize("Flash, off")
                self?.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            }
        }

        cameraController.torchChangedHandler = { [weak self] hasTorch, torchMode, torchAvailable in
            self?.flashButton.hidden = !hasTorch
            self?.flashButton.enabled = torchAvailable

            let bundle = NSBundle(forClass: CameraViewController.self)

            switch torchMode {
            case .Auto:
                self?.flashButton.accessibilityLabel = Localize("Flash, automatic")
                self?.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .On:
                self?.flashButton.accessibilityLabel = Localize("Flash, on")
                self?.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            case .Off:
                self?.flashButton.accessibilityLabel = Localize("Flash, off")
                self?.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
            }
        }

        cameraController.sessionInterruptionHandler = { [weak self, unowned cameraController] interrupted in
            self?.buttonsEnabled = !interrupted

            guard let strongSelf = self else {
                return
            }

            if interrupted && strongSelf.snapshotView == nil {
                let videoPreviewView = cameraController.videoPreviewView
                videoPreviewView.hidden = true

                // Add a snapshot of the preview and show it immediately
                let snapshot = videoPreviewView.snapshotViewAfterScreenUpdates(false)
                snapshot.transform = videoPreviewView.transform
                snapshot.frame = strongSelf.cameraPreviewContainer.frame
                strongSelf.cameraPreviewContainer.superview?.insertSubview(snapshot, aboveSubview: videoPreviewView)

                // Create another snapshot with a visual effect view added
                let snapshotWithBlur = videoPreviewView.snapshotViewAfterScreenUpdates(false)
                snapshotWithBlur.transform = videoPreviewView.transform
                snapshotWithBlur.frame = strongSelf.cameraPreviewContainer.frame

                let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
                visualEffectView.frame = snapshotWithBlur.bounds
                visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                snapshotWithBlur.addSubview(visualEffectView)

                strongSelf.snapshotView = snapshotWithBlur

                // Transition between the two snapshots
                UIView.transitionFromView(snapshot, toView: snapshotWithBlur, duration: 0.4, options: [.TransitionCrossDissolve, .CurveEaseOut], completion: nil)
            } else {
                strongSelf.transitionFromSnapshotToLivePreviewAlongAnimations(nil)
            }
        }

        cameraController.sessionRuntimeErrorHandler = { [weak self] error in
            let alertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default) { handler in
                self?.cameraController?.startCamera()
            }

            alertController.addAction(action)

            self?.presentViewController(alertController, animated: true, completion: nil)
        }

        cameraController.authorizationFailedHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let alertController = UIAlertController(title: Localize("No permissions"), message: Localize("Permissions to use Camera are required, please change privacy settings."), preferredStyle: .Alert)

            let settingsAction = UIAlertAction(title: Localize("Settings"), style: .Default) { _ in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }

            let cancelAction = UIAlertAction(title: Localize("Cancel"), style: .Cancel, handler: nil)

            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)

            strongSelf.presentViewController(alertController, animated: true, completion: nil)
        }

        cameraController.videoRecordingStartedHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            UIView.animateWithDuration(0.25) {
                strongSelf.swipeLeftGestureRecognizer.enabled = false
                strongSelf.swipeRightGestureRecognizer.enabled = false

                strongSelf.switchCameraButton.alpha = 0
                strongSelf.filterSelectionButton.alpha = 0
                strongSelf.bottomControlsView.backgroundColor = UIColor.clearColor()

                for recordingModeSelectionButton in strongSelf.recordingModeSelectionButtons {
                    recordingModeSelectionButton.alpha = 0
                }
            }
        }

        cameraController.videoRecordingFailedHandler = { [weak self] in
            self?.updateUIForStoppedRecording()

            let alertController = UIAlertController(title: "Error", message: "Video recording failed", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self?.presentViewController(alertController, animated: true, completion: nil)
        }

        cameraController.videoRecordingFinishedHandler = { [weak self] fileURL in
            self?.updateUIForStoppedRecording()

            if let completionBlock = self?.completionBlock {
                completionBlock(nil, fileURL)
            } else {
                self?.saveMovieWithMovieURLToAssets(fileURL)
            }
        }

        cameraController.videoRecordingProgressHandler = { [weak self] seconds in
            guard let strongSelf = self else {
                return
            }

            let displayedSeconds: Int

            if strongSelf.options.maximumVideoLength > 0 {
                displayedSeconds = strongSelf.options.maximumVideoLength - seconds
            } else {
                displayedSeconds = seconds
            }

            strongSelf.updateRecordingTimeLabel(displayedSeconds)

            if strongSelf.options.maximumVideoLength > 0 && seconds >= strongSelf.options.maximumVideoLength {
                self?.cameraController?.stopVideoRecording()
            }
        }

        cameraController.previewFrameChangedHandler = { [weak self] previewFrame in
            self?.updateSquareIndicatorView(previewFrame)
        }

        cameraController.focusPointChangedHandler = { [weak self, unowned cameraController] point in
            guard let strongSelf = self else {
                return
            }

            let convertedPoint = cameraController.videoPreviewView.convertPoint(point, toView: strongSelf.cameraPreviewContainer)
            strongSelf.showFocusIndicatorLayerAtLocation(convertedPoint)
        }

        cameraController.focusModeChangedHandler = { [weak self] focusMode, exposureMode in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.focusIndicatorLayer.hidden == false {
                if focusMode == .Locked && exposureMode == .Locked {
                    strongSelf.focusIndicatorLayer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
                }
            }
        }

        cameraController.focusDisabledHandler = { [weak self] in
            self?.disableFocusLockAnimated(true)
        }

        do {
            try cameraController.setupWithInitialRecordingMode(options.allowedRecordingModes[0])
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
        cameraController.videoPreviewView.isAccessibilityElement = true
        cameraController.videoPreviewView.accessibilityTraits |= UIAccessibilityTraitImage
        cameraController.videoPreviewView.accessibilityLabel = Localize("Viewfinder")
        cameraController.videoPreviewView.frame = cameraPreviewContainer.bounds
        self.cameraController = cameraController
    }

    private func configureFilterSelectionController() {
        filterSelectionController.dataSource = self.options.filtersDataSource
        filterSelectionController.selectedBlock = { [weak self] filterType, initialFilterIntensity in
            if let cameraController = self?.cameraController where cameraController.effectFilter.filterType != filterType {
                cameraController.effectFilter = InstanceFactory.effectFilterWithType(filterType)
                cameraController.effectFilter.inputIntensity = initialFilterIntensity
                self?.filterIntensitySlider.value = initialFilterIntensity
            }

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

        filterSelectionController.activeFilterType = { [weak self] in
            if let cameraController = self?.cameraController {
                return cameraController.effectFilter.filterType
            } else {
                return .None
            }
        }
    }

    // MARK: - Helpers

    private func updateRecordingTimeLabel(seconds: Int) {
        self.recordingTimeLabel.text = NSString(format: "%02d:%02d", seconds / 60, seconds % 60) as String
        self.recordingTimeLabel.accessibilityLabel = NSString.localizedStringWithFormat(Localize("%d seconds"), seconds) as String
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
            editorViewController.initialFilterType = cameraController.effectFilter.filterType
            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
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
                        let alertController = UIAlertController(title: Localize("Error while saving video"), message: error.localizedDescription, preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: Localize("Cancel"), style: .Cancel, handler: nil)

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

    private func transitionFromSnapshotToLivePreviewAlongAnimations(animations: (() -> Void)?) {
        if let snapshot = snapshotView, cameraController = cameraController {
            cameraController.videoPreviewView.alpha = 0
            cameraController.videoPreviewView.hidden = false

            // Giving the preview view a bit of time to redraw first
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.2, animations: {
                    snapshot.alpha = 0
                    cameraController.videoPreviewView.alpha = 1
                    animations?()
                    }) { _ in
                        // Deleting the blurred snapshot
                        snapshot.removeFromSuperview()
                        self.snapshotView = nil
                        self.cameraTransitionComplete = nil
                }
            }
        }
    }

    private func changeToRecordingMode(recordingMode: RecordingMode) {
        guard let cameraController = cameraController else {
            return
        }

        buttonsEnabled = false
        focusIndicatorLayer.hidden = true

        if let centerModeButtonConstraint = centerModeButtonConstraint {
            bottomControlsView.removeConstraint(centerModeButtonConstraint)
        }

        // add new action button to container
        let actionButton = recordingMode.actionButton
        actionButton.addTarget(self, action: recordingMode.actionSelector, forControlEvents: .TouchUpInside)
        actionButton.alpha = 0
        addActionButtonToContainer(actionButton)

        // Call configuration closure if actionButton is a UIButton subclass
        if let imageCaptureActionButton = actionButton as? UIButton {
            options.photoActionButtonConfigurationClosure?(imageCaptureActionButton)
        }

        actionButton.layoutIfNeeded()

        let buttonIndex = options.allowedRecordingModes.indexOf(recordingMode)!
        if buttonIndex < recordingModeSelectionButtons.count {
            let target = recordingModeSelectionButtons[buttonIndex]

            // create new centerModeButtonConstraint
            self.centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .CenterX, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0)
            self.bottomControlsView.addConstraint(centerModeButtonConstraint!)
        }

        // add recordingTimeLabel
        if recordingMode == .Video {
            self.addRecordingTimeLabel()
            self.hideSquareMask()
        } else {
            if options.cropToSquare {
                self.showSquareMask()
            }
        }

        let videoPreviewView = cameraController.videoPreviewView
        videoPreviewView.hidden = true

        // Add a snapshot of the preview and show it immediately
        let snapshot = videoPreviewView.snapshotViewAfterScreenUpdates(false)
        snapshot.transform = videoPreviewView.transform
        snapshot.frame = cameraPreviewContainer.frame
        cameraPreviewContainer.superview?.insertSubview(snapshot, aboveSubview: videoPreviewView)

        // Switch recording mode
        cameraController.recordingMode = recordingMode

        // Create another snapshot with a visual effect view added
        let snapshotWithBlur = videoPreviewView.snapshotViewAfterScreenUpdates(false)
        snapshotWithBlur.transform = videoPreviewView.transform
        snapshotWithBlur.frame = cameraPreviewContainer.frame

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = snapshotWithBlur.bounds
        visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        snapshotWithBlur.addSubview(visualEffectView)
        snapshotWithBlur.alpha = 0

        cameraPreviewContainer.superview?.insertSubview(snapshotWithBlur, belowSubview: snapshot)

        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
            // Crossfade between regular and blurred snapshot
            snapshot.alpha = 0
            snapshotWithBlur.alpha = 1

            let recordingModes = self.options.allowedRecordingModes
            let buttonIndex = recordingModes.indexOf(recordingMode)!
            if buttonIndex < self.recordingModeSelectionButtons.count {
                let target = self.recordingModeSelectionButtons[buttonIndex]

                // mark target as selected
                target.selected = true

                // deselect all other buttons
                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                    if recordingModeSelectionButton != target {
                        recordingModeSelectionButton.selected = false
                    }
                }
            }

            // fade new action button in and old action button out
            let actionButton = self.actionButtonContainer.subviews.last as? UIControl

            // fetch previous action button from container
            let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
            actionButton?.alpha = 1

            if let previousActionButton = previousActionButton, actionButton = actionButton where previousActionButton != actionButton {
                previousActionButton.alpha = 0
            }

            self.cameraRollButton.alpha = recordingMode == .Video ? 0 : 1

            self.bottomControlsView.layoutIfNeeded()
            }) { _ in
                snapshot.removeFromSuperview()

                if self.actionButtonContainer.subviews.count > 1 {
                    // fetch previous action button from container
                    let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl

                    // remove old action button
                    previousActionButton?.removeFromSuperview()
                }

                self.updateConstraintsForRecordingMode(recordingMode)
                self.snapshotView = snapshotWithBlur

                // If the actual camera change is already done at this point, immediately transition to the live preview
                if let cameraTransitionComplete = self.cameraTransitionComplete where cameraTransitionComplete == true {
                    self.transitionFromSnapshotToLivePreviewAlongAnimations {
                        // update constraints for view hierarchy
                        self.updateViewsForRecordingMode(recordingMode)
                        self.recordingTimeLabel.alpha = recordingMode == .Video ? 1 : 0
                    }
                }
        }
    }

    // MARK: - Targets

    @objc private func toggleMode(sender: AnyObject?) {
        let recordingModes = options.allowedRecordingModes

        guard let cameraController = cameraController else {
            return
        }

        if let gestureRecognizer = sender as? UISwipeGestureRecognizer {
            if gestureRecognizer.direction == .Left {
                let currentIndex = recordingModes.indexOf(cameraController.recordingMode)

                if let currentIndex = currentIndex where currentIndex < recordingModes.count - 1 {
                    changeToRecordingMode(recordingModes[currentIndex + 1])
                    return
                }
            } else if gestureRecognizer.direction == .Right {
                let currentIndex = recordingModes.indexOf(cameraController.recordingMode)

                if let currentIndex = currentIndex where currentIndex > 0 {
                    changeToRecordingMode(recordingModes[currentIndex - 1])
                    return
                }
            }
        }

        if let button = sender as? UIButton {
            let buttonIndex = recordingModeSelectionButtons.indexOf(button)

            if let buttonIndex = buttonIndex {
                changeToRecordingMode(recordingModes[buttonIndex])
                return
            }
        }
    }

    @objc private func hideFilterIntensitySlider(timer: NSTimer?) {
        UIView.animateWithDuration(0.25) {
            self.filterIntensitySlider.alpha = 0
            self.hideSliderTimer = nil
        }
    }

    public func changeFlash(sender: UIButton?) {
        cameraController?.selectNextLightMode()
    }

    public func switchCamera(sender: UIButton?) {
        buttonsEnabled = false
        cameraController?.toggleCameraPosition()

        if let videoPreviewView = cameraController?.videoPreviewView {
            // Hide live preview
            cameraController?.videoPreviewView.hidden = true

            // Add a snapshot of the preview and show it immediately
            let snapshot = videoPreviewView.snapshotViewAfterScreenUpdates(false)
            snapshot.transform = videoPreviewView.transform
            snapshot.frame = cameraPreviewContainer.frame
            cameraPreviewContainer.superview?.insertSubview(snapshot, aboveSubview: videoPreviewView)

            // Create another snapshot with a visual effect view added
            let snapshotWithBlur = videoPreviewView.snapshotViewAfterScreenUpdates(false)
            snapshotWithBlur.transform = videoPreviewView.transform
            snapshotWithBlur.frame = cameraPreviewContainer.frame

            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            visualEffectView.frame = snapshotWithBlur.bounds
            visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            snapshotWithBlur.addSubview(visualEffectView)

            // Transition between the two snapshots
            UIView.transitionFromView(snapshot, toView: snapshotWithBlur, duration: 0.4, options: [.TransitionFlipFromLeft, .CurveEaseOut]) { _ in
                self.snapshotView = snapshotWithBlur

                // If the actual camera change is already done at this point, immediately transition to the live preview
                if let cameraTransitionComplete = self.cameraTransitionComplete where cameraTransitionComplete == true {
                    self.transitionFromSnapshotToLivePreviewAlongAnimations(nil)
                }
            }
        }
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
        cameraController?.takePhoto { image, error in
            if error == nil {
                let updatedImage: UIImage?

                if let
                    cameraController = self.cameraController,
                    image = image where self.options.cropToSquare {
                        var scale = image.size.width / image.size.height
                        if let captureVideoOrientation = cameraController.deviceOrientationController.captureVideoOrientation {
                            if captureVideoOrientation == .LandscapeRight || captureVideoOrientation == .LandscapeLeft {
                                scale = image.size.height / image.size.width
                            }
                        }

                        let offset = (1.0 - scale) / 2.0
                        let orientationCropFilter = InstanceFactory.orientationCropFilter()
                        orientationCropFilter.cropRect = CGRect(x: offset, y: 0, width: scale, height: 1)

                        updatedImage = PhotoProcessor.processWithUIImage(image, filters: [orientationCropFilter])
                } else {
                    updatedImage = image
                }

                dispatch_async(dispatch_get_main_queue()) {
                    if let completionBlock = self.completionBlock {
                        completionBlock(updatedImage, nil)
                    } else {
                        if let updatedImage = updatedImage {
                            self.showEditorNavigationControllerWithImage(updatedImage)
                        }
                    }
                }
            }
        }
    }

    public func recordVideo(sender: VideoRecordButton?) {
        if let recordVideoButton = sender {
            if recordVideoButton.recording {
                cameraController?.startVideoRecording()
            } else {
                cameraController?.stopVideoRecording()
            }

            if let filterSelectionViewConstraint = filterSelectionViewConstraint where filterSelectionViewConstraint.constant != 0 {
                toggleFilters(filterSelectionButton)
            }
        }
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
            cameraController?.effectFilter.inputIntensity = slider.value
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

    // MARK: - Recording UI

    private func updateUIForStoppedRecording() {
        UIView.animateWithDuration(0.25) {
            self.swipeLeftGestureRecognizer.enabled = true
            self.swipeRightGestureRecognizer.enabled = true

            self.switchCameraButton.alpha = 1
            self.filterSelectionButton.alpha = 1
            self.bottomControlsView.backgroundColor = self.currentBackgroundColor.colorWithAlphaComponent(0.3)

            self.updateRecordingTimeLabel(self.options.maximumVideoLength)

            for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                recordingModeSelectionButton.alpha = 1
            }

            if let actionButton = self.actionButtonContainer.subviews.first as? VideoRecordButton {
                actionButton.recording = false
            }
        }
    }

    // MARK: - Square

    private func configureMaskLayers() {
        cameraPreviewContainer.layer.addSublayer(maskIndicatorLayer)
        cameraPreviewContainer.layer.addSublayer(upperMaskDarkenLayer)
        cameraPreviewContainer.layer.addSublayer(lowerMaskDarkenLayer)
        cameraPreviewContainer.layer.addSublayer(focusIndicatorLayer)
    }

    /*
    Please note, the calculations in this method might look a bit weird.
    The reason is that the frame we are getting is rotated by 90 degree
    */
    private func updateSquareIndicatorView(newRect: CGRect) {
        let width = newRect.size.height / 2.0
        let height = width
        let top = newRect.origin.x + ((newRect.size.width / 2.0) - width) / 2.0
        let left = newRect.origin.y / 2.0
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        maskIndicatorLayer.frame = CGRect(x: left, y: top, width: width, height: height).integral
        upperMaskDarkenLayer.frame = CGRect(x: left, y: 0, width: width, height: top - 1).integral
        // add extra space to the bottom to avoid a gab due to the lower bar animation
        lowerMaskDarkenLayer.frame = CGRect(x: left, y: top + height + 1, width: width, height: top * 2).integral
        CATransaction.commit()
    }

    func showSquareMask() {
        maskIndicatorLayer.hidden = false
        upperMaskDarkenLayer.hidden = false
        lowerMaskDarkenLayer.hidden = false
    }

    func hideSquareMask() {
        maskIndicatorLayer.hidden = true
        upperMaskDarkenLayer.hidden = true
        lowerMaskDarkenLayer.hidden = true
    }

    // MARK: - Focus

    private var focusIndicatorFadeOutTimer: NSTimer?
    private var focusIndicatorAnimating = false

    private func showFocusIndicatorLayerAtLocation(location: CGPoint) {
        focusIndicatorFadeOutTimer?.invalidate()
        focusIndicatorFadeOutTimer = nil
        focusIndicatorAnimating = false

        CATransaction.begin()
        focusIndicatorLayer.opacity = 1
        focusIndicatorLayer.hidden = false
        focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
        focusIndicatorLayer.frame.size = CGSize(width: kIndicatorSize, height: kIndicatorSize)
        focusIndicatorLayer.position = location
        focusIndicatorLayer.transform = CATransform3DIdentity
        focusIndicatorLayer.removeAllAnimations()
        CATransaction.commit()

        let resizeAnimation = CABasicAnimation(keyPath: "transform")
        resizeAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1))
        resizeAnimation.duration = 0.25
        focusIndicatorLayer.addAnimation(resizeAnimation, forKey: nil)
    }

    private func disableFocusLockAnimated(animated: Bool) {
        if focusIndicatorAnimating {
            return
        }

        focusIndicatorAnimating = true
        focusIndicatorFadeOutTimer?.invalidate()

        if animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
            focusIndicatorLayer.frame.size = CGSize(width: kIndicatorSize * 2, height: kIndicatorSize * 2)
            focusIndicatorLayer.transform = CATransform3DIdentity
            focusIndicatorLayer.position = cameraPreviewContainer.center

            CATransaction.commit()

            let resizeAnimation = CABasicAnimation(keyPath: "transform")
            resizeAnimation.duration = 0.25
            resizeAnimation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(1.5, 1.5, 1))
            resizeAnimation.delegate = AnimationDelegate(block: { finished in
                if finished {
                    self.focusIndicatorFadeOutTimer = NSTimer.after(0.85) { [unowned self] in
                        self.focusIndicatorLayer.opacity = 0

                        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                        fadeAnimation.duration = 0.25
                        fadeAnimation.fromValue = 1
                        fadeAnimation.delegate = AnimationDelegate() { finished in
                            if finished {
                                CATransaction.begin()
                                CATransaction.setDisableActions(true)
                                self.focusIndicatorLayer.hidden = true
                                self.focusIndicatorLayer.opacity = 1
                                self.focusIndicatorLayer.frame.size = CGSize(width: kIndicatorSize, height: kIndicatorSize)
                                CATransaction.commit()
                                self.focusIndicatorAnimating = false
                            }
                        }

                        self.focusIndicatorLayer.addAnimation(fadeAnimation, forKey: nil)
                    }
                }
            })

            focusIndicatorLayer.addAnimation(resizeAnimation, forKey: nil)
        } else {
            focusIndicatorLayer.hidden = true
            focusIndicatorAnimating = false
        }
    }
}

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
