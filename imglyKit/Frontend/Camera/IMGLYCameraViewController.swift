//
//  IMGLYCameraViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

private let ShowFilterIntensitySliderInterval = NSTimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias IMGLYCameraCompletionBlock = (UIImage?, NSURL?) -> (Void)

@objc public class IMGLYCameraViewControllerOptions: NSObject {
    
    // MARK: UI
    
    /// The views background color. In video mode the colors alpha value is reduced to 0.3.
    /// Defaults to the global background color.
    public var backgroundColor: UIColor?
    
    /// Use this closure to configure the flash button. Defaults to an empty implementation.
    public lazy var flashButtonConfigurationClosure: IMGLYButtonConfigurationClosure = { _ in }
    
    /// Use this closure to configure the switch camera button. Defaults to an empty implementation.
    public lazy var switchCameraButtonConfigurationClosure: IMGLYButtonConfigurationClosure = { _ in }
    
    /// Use this closure to configure the camera roll button. Defaults to an empty implementation.
    public lazy var cameraRollButtonConfigurationClosure: IMGLYButtonConfigurationClosure = { _ in }
    
    /// Use this closure to configure the action button in photo mode. Defaults to an empty implementation.
    public lazy var photoActionButtonConfigurationClosure: IMGLYButtonConfigurationClosure = { _ in }
    
    /// Use this closure to configure the filter selector button. Defaults to an empty implementation.
    public lazy var filterSelectorButtonConfigurationClosure: IMGLYButtonConfigurationClosure = { _ in }
    
    /// Use this closure to configure the timelabel. Defaults to an empty implementation.
    public lazy var timeLabelConfigurationClosure: IMGLYLabelConfigurationClosure = { _ in }
    
    /// Use this closure to configure the filter intensity slider. Defaults to an empty implementation.
    public lazy var filterIntensitySliderConfigurationClosure: IMGLYSliderConfigurationClosure = { _ in }
    
    // MARK: Behaviour
    
    /// Enable/Disable permanent crop to square.
    public var cropToSquare = false
    
    /// Enable/Disable tap to focus on the camera preview image.
    public var tapToFocusEnabled = true
    
    /// Show/Hide the camera roll button.
    public var showCameraRoll = true
    
    /// Enable/Disable filter bottom drawer.
    public var showFilters = true
    
    /// An object conforming to the `IMGLYFilterSelectionControllerDataSourceProtocol`
    public var filterDataSource: IMGLYFilterSelectionControllerDataSourceProtocol = IMGLYFilterSelectionControllerDataSource()
    
    /// Enable/Disable filter intensity slider.
    public var showFilterIntensitySlider = true
    
    /// Allowed camera positions. Defaults to all available positions
    /// and falls back to supported position if only one exists.
    public var allowedCameraPositions: [IMGLYCameraPosition] = [ .Back, .Front ]
    
    /// Allowed flash modes. Defaults to all available modes.
    public var allowedFlashModes: [IMGLYFlashMode] = [ .Auto, .On, .Off ]

    /// Allowed torch modes. Defaults to all available modes.
    public var allowedTorchModes: [IMGLYTorchMode] = [ .Auto, .On, .Off ]
}

public class IMGLYCameraViewController: UIViewController {
    
    private let configuration: IMGLYConfiguration
    private var currentBackgroundColor: UIColor {
        get {
            if let customBackgroundColor = self.configuration.cameraViewControllerOptions.backgroundColor {
                return customBackgroundColor
            }
            
            return configuration.backgroundColor
        }
    }
    
    // MARK: - Initializers
    
    public convenience init(configuration: IMGLYConfiguration = IMGLYConfiguration()) {
        self.init(recordingModes: [.Photo, .Video], configuration: configuration)
    }
    
    /// This initializer should only be used in Objective-C. It expects an NSArray of NSNumbers that wrap
    /// the integer value of IMGLYRecordingMode.
    public convenience init(recordingModes: [NSNumber], configuration: IMGLYConfiguration = IMGLYConfiguration()) {
        let modes = recordingModes.map { IMGLYRecordingMode(rawValue: $0.integerValue) }.filter { $0 != nil }.map { $0! }
        self.init(recordingModes: modes, configuration: configuration)
    }
    
    /**
     Initializes a camera view controller using the given parameters.
     
    - parameter recordingModes: An array of recording modes that you want to support.
    - parameter configuration: An IMGLYConfiguration object
     
    - returns: An initialized IMGLYCameraViewController.
    
    - discussion: If you use the standard `init` method or `initWithCoder` to initialize a `IMGLYCameraViewController` object, a camera view controller with all supported recording modes and the default configuration is created.
    */
    public init(recordingModes: [IMGLYRecordingMode], configuration: IMGLYConfiguration = IMGLYConfiguration()) {
        assert(recordingModes.count > 0, "You need to set at least one recording mode.")
        self.recordingModes = recordingModes
        self.currentRecordingMode = recordingModes.first!
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        recordingModes = [.Photo, .Video]
        currentRecordingMode = recordingModes.first!
        self.configuration = IMGLYConfiguration()
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
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setImage(buttonImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.contentHorizontalAlignment = .Left
        button.addTarget(self, action: "changeFlash:", forControlEvents: .TouchUpInside)
        button.hidden = true
        self.configuration.cameraViewControllerOptions.flashButtonConfigurationClosure(button)
        return button
        }()
    
    private lazy var switchCameraButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "cam_switch", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setImage(buttonImage!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.contentHorizontalAlignment = .Right
        button.addTarget(self, action: "switchCamera:", forControlEvents: .TouchUpInside)
        button.hidden = true
        self.configuration.cameraViewControllerOptions.switchCameraButtonConfigurationClosure(button)
        return button
        }()
    
    private lazy var cameraRollButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.imageView?.contentMode = .ScaleAspectFill
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "showCameraRoll:", forControlEvents: .TouchUpInside)
        self.configuration.cameraViewControllerOptions.cameraRollButtonConfigurationClosure(button)
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
        self.configuration.cameraViewControllerOptions.timeLabelConfigurationClosure(label)
        return label
    }()
    
    public private(set) var actionButton: UIControl?
    
    public private(set) lazy var filterSelectionButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "show_filter", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "toggleFilters:", forControlEvents: .TouchUpInside)
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.configuration.cameraViewControllerOptions.filterSelectorButtonConfigurationClosure(button)
        return button
        }()
    
    public private(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = NSBundle(forClass: self.dynamicType)
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
        
        self.configuration.cameraViewControllerOptions.filterIntensitySliderConfigurationClosure(slider)
        
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
    
    public let recordingModes: [IMGLYRecordingMode]
    private var recordingModeSelectionButtons = [UIButton]()
    
    public private(set) var currentRecordingMode: IMGLYRecordingMode {
        didSet {
            if currentRecordingMode == oldValue {
                return
            }
            
            self.cameraController?.switchToRecordingMode(self.currentRecordingMode)
        }
    }

    private var hideSliderTimer: NSTimer?
    
    private var filterSelectionViewConstraint: NSLayoutConstraint?
    public let filterSelectionController = IMGLYFilterSelectionController()
    
    public private(set) var cameraController: IMGLYCameraController?
    
    /// The maximum length of a video. If set to 0 the length is unlimited.
    public var maximumVideoLength: Int = 0 {
        didSet {
            if maximumVideoLength == 0 {
                cameraController?.maximumVideoLength = nil
            } else {
                cameraController?.maximumVideoLength = maximumVideoLength
            }
            
            updateRecordingTimeLabel(maximumVideoLength)
        }
    }
    
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
    
    public var completionBlock: IMGLYCameraCompletionBlock?
    
    private var centerModeButtonConstraint: NSLayoutConstraint?
    private var cameraPreviewContainerTopConstraint: NSLayoutConstraint?
    private var cameraPreviewContainerBottomConstraint: NSLayoutConstraint?
    
    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureRecordingModeSwitching()
        configureViewHierarchy()
        configureViewConstraints()
        configureFilterSelectionController()
        configureCameraController()
        cameraController?.switchToRecordingMode(currentRecordingMode, animated: false)
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
        if recordingModes.count > 1 {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)
            
            recordingModeSelectionButtons = recordingModes.map { $0.selectionButton }
            
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
    
        if configuration.cameraViewControllerOptions.showCameraRoll {
            bottomControlsView.addSubview(cameraRollButton)
        }
    
        if configuration.cameraViewControllerOptions.showFilters {
            bottomControlsView.addSubview(filterSelectionButton)
        }
        
        for recordingModeSelectionButton in recordingModeSelectionButtons {
            bottomControlsView.addSubview(recordingModeSelectionButton)
        }
        
        if configuration.cameraViewControllerOptions.showFilterIntensitySlider {
            backgroundContainerView.addSubview(filterIntensitySlider)
        }
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
            "filterSelectionViewHeight" : FilterSelectionViewHeight,
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
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        cameraRollButton.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .CenterY, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: cameraRollButton, attribute: .Left, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Left, multiplier: 1, constant: 20))
        
        // ActionButtonContainer
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70))
        actionButtonContainer.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: actionButtonContainer, attribute: .CenterX, relatedBy: .Equal, toItem: bottomControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Bottom, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .Bottom, multiplier: 1, constant: 10))
        
        // FilterSelectionButton
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.width))
        filterSelectionButton.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: BottomControlSize.height))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: filterSelectionButton, attribute: .CenterY, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Right, relatedBy: .Equal, toItem: filterSelectionButton, attribute: .Right, multiplier: 1, constant: 20))
    }
    
    private func configureCameraController() {
        // Needed so that the framebuffer can bind to OpenGL ES
        view.layoutIfNeeded()
        
        cameraController = IMGLYCameraController(previewView: cameraPreviewContainer)
        cameraController!.tapToFocusEnabled = configuration.cameraViewControllerOptions.tapToFocusEnabled
        cameraController!.allowedCameraPositions = configuration.cameraViewControllerOptions.allowedCameraPositions
        cameraController!.allowedFlashModes = configuration.cameraViewControllerOptions.allowedFlashModes
        cameraController!.allowedTorchModes = configuration.cameraViewControllerOptions.allowedTorchModes
        cameraController!.squareMode = configuration.cameraViewControllerOptions.cropToSquare
        cameraController!.delegate = self
        cameraController!.setupWithInitialRecordingMode(currentRecordingMode)
        if maximumVideoLength > 0 {
            cameraController!.maximumVideoLength = maximumVideoLength
        }
    }
    
    private func configureFilterSelectionController() {
        filterSelectionController.dataSource = self.configuration.cameraViewControllerOptions.filterDataSource
        filterSelectionController.selectedBlock = { [weak self] filterType, initialFilterIntensity in
            if let cameraController = self?.cameraController where cameraController.effectFilter.filterType != filterType {
                cameraController.effectFilter = IMGLYInstanceFactory.effectFilterWithType(filterType)
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
    }
    
    private func addRecordingTimeLabel() {
        updateRecordingTimeLabel(maximumVideoLength)
        topControlsView.addSubview(recordingTimeLabel)
        
        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: topControlsView, attribute: .CenterX, multiplier: 1, constant: 0))
        topControlsView.addConstraint(NSLayoutConstraint(item: recordingTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: topControlsView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    private func updateConstraintsForRecordingMode(recordingMode: IMGLYRecordingMode) {
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
    
    private func updateViewsForRecordingMode(recordingMode: IMGLYRecordingMode) {
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
    
    private func updateFlashButton() {
        if let cameraController = cameraController {
            let bundle = NSBundle(forClass: self.dynamicType)

            if currentRecordingMode == .Photo {
                flashButton.hidden = !cameraController.flashAvailable
                
                switch(cameraController.flashMode) {
                case .Auto:
                    self.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                case .On:
                    self.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                case .Off:
                    self.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                }
            } else if currentRecordingMode == .Video {
                flashButton.hidden = !cameraController.torchAvailable
                
                switch(cameraController.torchMode) {
                case .Auto:
                    self.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                case .On:
                    self.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                case .Off:
                    self.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
                }
            }
        } else {
            flashButton.hidden = true
        }
    }
    
    private func resetHideSliderTimer() {
        hideSliderTimer?.invalidate()
        hideSliderTimer = NSTimer.scheduledTimerWithTimeInterval(ShowFilterIntensitySliderInterval, target: self, selector: "hideFilterIntensitySlider:", userInfo: nil, repeats: false)
    }
    
    private func showEditorNavigationControllerWithImage(image: UIImage) {
        let editorViewController = self.configuration.getClassForReplacedClass(IMGLYMainEditorViewController.self).init() as! IMGLYMainEditorViewController
        editorViewController.configuration = configuration
        editorViewController.highResolutionImage = image
        if let cameraController = cameraController {
            editorViewController.initialFilterType = cameraController.effectFilter.filterType
            editorViewController.initialFilterIntensity = cameraController.effectFilter.inputIntensity
        }
        editorViewController.completionBlock = editorCompletionBlock
        
        let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
        navigationController.navigationBar.barStyle = .Black
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    private func saveMovieWithMovieURLToAssets(movieURL: NSURL) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(movieURL)
            }) { success, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        let bundle = NSBundle(forClass: self.dynamicType)
                        
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
        if fetchResult.lastObject != nil {
            let lastAsset: PHAsset = fetchResult.lastObject as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: CGSize(width: BottomControlSize.width * 2, height: BottomControlSize.height * 2), contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (result, info) -> Void in
                self.cameraRollButton.setImage(result, forState: UIControlState.Normal)
            }
        }
    }
    
    // MARK: - Targets
    
    @objc private func toggleMode(sender: AnyObject?) {
        if let gestureRecognizer = sender as? UISwipeGestureRecognizer {
            if gestureRecognizer.direction == .Left {
                let currentIndex = recordingModes.indexOf(currentRecordingMode)
                
                if let currentIndex = currentIndex where currentIndex < recordingModes.count - 1 {
                    currentRecordingMode = recordingModes[currentIndex + 1]
                    return
                }
            } else if gestureRecognizer.direction == .Right {
                let currentIndex = recordingModes.indexOf(currentRecordingMode)
                
                if let currentIndex = currentIndex where currentIndex > 0 {
                    currentRecordingMode = recordingModes[currentIndex - 1]
                    return
                }
            }
        }
        
        if let button = sender as? UIButton {
            let buttonIndex = recordingModeSelectionButtons.indexOf(button)
            
            if let buttonIndex = buttonIndex {
                currentRecordingMode = recordingModes[buttonIndex]
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
        switch(currentRecordingMode) {
        case .Photo:
            cameraController?.selectNextFlashMode()
        case .Video:
            cameraController?.selectNextTorchMode()
        }
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
        cameraController?.takePhoto { image, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if let completionBlock = self.completionBlock {
                        completionBlock(image, nil)
                    } else {
                        if let image = image {
                            self.showEditorNavigationControllerWithImage(image)
                        }
                    }
                }
            }
        }
    }
    
    public func recordVideo(sender: IMGLYVideoRecordButton?) {
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
                filterSelectionViewConstraint.constant = -1 * CGFloat(FilterSelectionViewHeight)
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
    
    private func editorCompletionBlock(result: IMGLYEditorResult, image: UIImage?) {
        if let image = image where result == .Done {
            UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>) {
        setLastImageFromRollAsPreview()
    }

}

extension IMGLYCameraViewController: IMGLYCameraControllerDelegate {
    public func cameraControllerDidStartCamera(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = true
        }
    }
    
    public func cameraControllerDidStopCamera(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidStartStillImageCapture(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            // Animate the actionButton if it is a UIButton and has a sequence of images set
            (self.actionButtonContainer.subviews.first as? UIButton)?.imageView?.startAnimating()
            self.buttonsEnabled = false
        }
    }
    
    public func cameraControllerDidFailAuthorization(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            let bundle = NSBundle(forClass: self.dynamicType)

            let alertController = UIAlertController(title: NSLocalizedString("camera-view-controller.camera-no-permission.title", tableName: nil, bundle: bundle, value: "", comment: ""), message: NSLocalizedString("camera-view-controller.camera-no-permission.message", tableName: nil, bundle: bundle, value: "", comment: ""), preferredStyle: .Alert)
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.settings", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Default) { _ in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("camera-view-controller.camera-no-permission.cancel", tableName: nil, bundle: bundle, value: "", comment: ""), style: .Cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didChangeToFlashMode flashMode: AVCaptureFlashMode) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateFlashButton()
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didChangeToTorchMode torchMode: AVCaptureTorchMode) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateFlashButton()
        }
    }
    
    public func cameraControllerDidCompleteSetup(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateFlashButton()
            self.switchCameraButton.hidden = !cameraController.moreThanOneCameraPresent
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, willSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = false
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didSwitchToCameraPosition cameraPosition: AVCaptureDevicePosition) {
        dispatch_async(dispatch_get_main_queue()) {
            self.buttonsEnabled = true
            self.updateFlashButton()
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, willSwitchToRecordingMode recordingMode: IMGLYRecordingMode) {
        buttonsEnabled = false
        
        if let centerModeButtonConstraint = centerModeButtonConstraint {
            bottomControlsView.removeConstraint(centerModeButtonConstraint)
        }
        
        // add new action button to container
        let actionButton = currentRecordingMode.actionButton
        actionButton.addTarget(self, action: currentRecordingMode.actionSelector, forControlEvents: .TouchUpInside)
        actionButton.alpha = 0
        self.addActionButtonToContainer(actionButton)
        // Call configuration closure if actionButton is a UIButton subclass
        if let imageCaptureActionButton = actionButton as? UIButton {
            self.configuration.cameraViewControllerOptions.photoActionButtonConfigurationClosure(imageCaptureActionButton)
        }
        actionButton.layoutIfNeeded()
        
        let buttonIndex = recordingModes.indexOf(currentRecordingMode)!
        if recordingModeSelectionButtons.count >= buttonIndex + 1 {
            let target = recordingModeSelectionButtons[buttonIndex]
            
            // create new centerModeButtonConstraint
            self.centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .CenterX, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0)
            self.bottomControlsView.addConstraint(centerModeButtonConstraint!)
        }
        
        // add recordingTimeLabel
        if recordingMode == .Video {
            self.addRecordingTimeLabel()
            self.cameraController?.hideSquareMask()
        } else {
            if configuration.cameraViewControllerOptions.cropToSquare {
                self.cameraController?.showSquareMask()
            }
        }
        
        self.view.bringSubviewToFront(self.filterIntensitySlider)
    }
    
    public func cameraController(cameraController: IMGLYCameraController, didSwitchToRecordingMode recordingMode: IMGLYRecordingMode) {
        dispatch_async(dispatch_get_main_queue()) {
            self.setLastImageFromRollAsPreview()
            self.buttonsEnabled = true
            
            if recordingMode == .Photo {
                self.recordingTimeLabel.removeFromSuperview()
            }
        }
    }
    
    public func cameraControllerAnimateAlongsideFirstPhaseOfRecordingModeSwitchBlock(cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            let buttonIndex = self.recordingModes.indexOf(self.currentRecordingMode)!
            if self.recordingModeSelectionButtons.count >= buttonIndex + 1 {
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
            
            self.cameraRollButton.alpha = self.currentRecordingMode == .Video ? 0 : 1
            
            self.bottomControlsView.layoutIfNeeded()
        }
    }
    
    public func cameraControllerFirstPhaseOfRecordingModeSwitchAnimationCompletionBlock(cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            if self.actionButtonContainer.subviews.count > 1 {
                // fetch previous action button from container
                let previousActionButton = self.actionButtonContainer.subviews.first as? UIControl
                
                // remove old action button
                previousActionButton?.removeFromSuperview()
            }
            
            self.updateConstraintsForRecordingMode(self.currentRecordingMode)
        }
    }
    
    public func cameraControllerAnimateAlongsideSecondPhaseOfRecordingModeSwitchBlock(cameraController: IMGLYCameraController) -> (() -> Void) {
        return {
            // update constraints for view hierarchy
            self.updateViewsForRecordingMode(self.currentRecordingMode)
            
            self.recordingTimeLabel.alpha = self.currentRecordingMode == .Video ? 1 : 0
        }
    }
    
    public func cameraControllerDidStartRecording(cameraController: IMGLYCameraController) {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25) {
                self.swipeLeftGestureRecognizer.enabled = false
                self.swipeRightGestureRecognizer.enabled = false
                
                self.switchCameraButton.alpha = 0
                self.filterSelectionButton.alpha = 0
                self.bottomControlsView.backgroundColor = UIColor.clearColor()
                
                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                    recordingModeSelectionButton.alpha = 0
                }
            }
        }
    }
    
    private func updateUIForStoppedRecording() {
        UIView.animateWithDuration(0.25) {
            self.swipeLeftGestureRecognizer.enabled = true
            self.swipeRightGestureRecognizer.enabled = true
            
            self.switchCameraButton.alpha = 1
            self.filterSelectionButton.alpha = 1
            self.bottomControlsView.backgroundColor = self.currentBackgroundColor.colorWithAlphaComponent(0.3)
            
            self.updateRecordingTimeLabel(self.maximumVideoLength)
            
            for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                recordingModeSelectionButton.alpha = 1
            }
            
            if let actionButton = self.actionButtonContainer.subviews.first as? IMGLYVideoRecordButton {
                actionButton.recording = false
            }
        }
    }
    
    public func cameraControllerDidFailRecording(cameraController: IMGLYCameraController, error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateUIForStoppedRecording()
            
            let alertController = UIAlertController(title: "Error", message: "Video recording failed", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    public func cameraControllerDidFinishRecording(cameraController: IMGLYCameraController, fileURL: NSURL) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateUIForStoppedRecording()
            if let completionBlock = self.completionBlock {
                completionBlock(nil, fileURL)
            } else {
                self.saveMovieWithMovieURLToAssets(fileURL)
            }
        }
    }
    
    public func cameraController(cameraController: IMGLYCameraController, recordedSeconds seconds: Int) {
        let displayedSeconds: Int
        
        if maximumVideoLength > 0 {
            displayedSeconds = maximumVideoLength - seconds
        } else {
            displayedSeconds = seconds
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.updateRecordingTimeLabel(displayedSeconds)
        }
    }
}

extension IMGLYCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
