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

let InitialFilterIntensity = Float(0.75)
private let ShowFilterIntensitySliderInterval = NSTimeInterval(2)
private let FilterSelectionViewHeight = 100
private let BottomControlSize = CGSize(width: 47, height: 47)
public typealias IMGLYCameraCompletionBlock = (UIImage?) -> (Void)

public class IMGLYCameraViewController: UIViewController {
    
    // MARK: - Initializers
    
    public convenience init() {
        self.init(recordingModes: [.Photo, .Video])
    }
    
    /// This initializer should only be used in Objective-C. It expects an NSArray of NSNumbers that wrap
    /// the integer value of IMGLYRecordingMode.
    public convenience init(recordingModes: [NSNumber]) {
        let modes = recordingModes.map { IMGLYRecordingMode(rawValue: $0.integerValue) }.filter { $0 != nil }.map { $0! }
        self.init(recordingModes: modes)
    }
    
    public init(recordingModes: [IMGLYRecordingMode]) {
        assert(recordingModes.count > 0, "You need to set at least one recording mode.")
        self.recordingModes = recordingModes
        self.currentRecordingMode = recordingModes.first!
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    public private(set) lazy var topControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    public private(set) lazy var cameraPreviewContainer: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.clipsToBounds = true
        return view
        }()
    
    public private(set) lazy var bottomControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
        }()
    
    public private(set) lazy var flashButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.contentHorizontalAlignment = .Left
        button.addTarget(self, action: "changeFlash:", forControlEvents: .TouchUpInside)
        button.hidden = true
        return button
        }()
    
    public private(set) lazy var switchCameraButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "cam_switch", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.contentHorizontalAlignment = .Right
        button.addTarget(self, action: "switchCamera:", forControlEvents: .TouchUpInside)
        button.hidden = true
        return button
        }()
    
    public private(set) lazy var cameraRollButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.imageView?.contentMode = .ScaleAspectFill
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "showCameraRoll:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var actionButtonContainer: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()
    
    public private(set) var actionButton: UIControl?
    
    public private(set) lazy var filterSelectionButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setImage(UIImage(named: "show_filter", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        button.addTarget(self, action: "toggleFilters:", forControlEvents: .TouchUpInside)
        button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        return button
        }()
    
    public private(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let slider = UISlider()
        slider.setTranslatesAutoresizingMaskIntoConstraints(false)
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
    
    private var currentRecordingMode: IMGLYRecordingMode {
        didSet {
            if currentRecordingMode == oldValue {
                return
            }
            
            if let centerModeButtonConstraint = centerModeButtonConstraint {
                bottomControlsView.removeConstraint(centerModeButtonConstraint)
            }

            let target = recordingModeSelectionButtons[find(recordingModes, currentRecordingMode)!]
            
            // disable target button and enable all other buttons
            target.userInteractionEnabled = false
            for recordingModeSelectionButton in recordingModeSelectionButtons {
                if recordingModeSelectionButton != target {
                    recordingModeSelectionButton.userInteractionEnabled = true
                }
            }
            
            // fetch previous action button from container
            let previousActionButton = actionButtonContainer.subviews.last as? UIControl
            
            // add new action button to container
            let actionButton = currentRecordingMode.actionButton
            actionButton.addTarget(self, action: currentRecordingMode.actionSelector, forControlEvents: .TouchUpInside)
            actionButton.alpha = 0
            addActionButtonToContainer(actionButton)
            actionButton.layoutIfNeeded()
        
            // create new centerModeButtonConstraint
            centerModeButtonConstraint = NSLayoutConstraint(item: target, attribute: .CenterX, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0)
            bottomControlsView.addConstraint(centerModeButtonConstraint!)
            
            UIView.animateWithDuration(0.25, animations: {
                self.cameraController?.switchToRecordingMode(self.currentRecordingMode)

                // update constraints for view hierarchy
                self.updateViewsForRecordingMode(self.currentRecordingMode)
                
                // mark target as selected
                target.selected = true
                
                // deselect all other buttons
                for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                    if recordingModeSelectionButton != target {
                        recordingModeSelectionButton.selected = false
                    }
                }
                
                // fade new action button in and old action button out
                actionButton.alpha = 1
                previousActionButton?.alpha = 0
                
                self.bottomControlsView.layoutIfNeeded()
                }) { finished in
                    // remove old action button
                    previousActionButton?.removeFromSuperview()
            }
        }
    }

    private var hideSliderTimer: NSTimer?
    
    private var filterSelectionViewConstraint: NSLayoutConstraint?
    public let filterSelectionController = IMGLYFilterSelectionController()
    
    public private(set) var cameraController: IMGLYCameraController?
    
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
        view.backgroundColor = UIColor.blackColor()
        
        configureRecordingModeSwitching()
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
        if recordingModes.count > 1 {
            view.addGestureRecognizer(swipeLeftGestureRecognizer)
            view.addGestureRecognizer(swipeRightGestureRecognizer)
            
            recordingModeSelectionButtons = recordingModes.map { $0.selectionButton }
            recordingModeSelectionButtons.first?.selected = true
            
            for recordingModeSelectionButton in recordingModeSelectionButtons {
                recordingModeSelectionButton.addTarget(self, action: "toggleMode:", forControlEvents: .TouchUpInside)
            }
        }

        let actionButton = recordingModes[0].actionButton
        actionButton.addTarget(self, action: recordingModes[0].actionSelector, forControlEvents: .TouchUpInside)
        addActionButtonToContainer(actionButton)
    }
    
    private func configureViewHierarchy() {
        view.addSubview(cameraPreviewContainer)
        view.addSubview(topControlsView)
        view.addSubview(bottomControlsView)
        
        addChildViewController(filterSelectionController)
        filterSelectionController.didMoveToParentViewController(self)
        view.addSubview(filterSelectionController.view)
        
        topControlsView.addSubview(flashButton)
        topControlsView.addSubview(switchCameraButton)
        
        bottomControlsView.addSubview(cameraRollButton)
        bottomControlsView.addSubview(actionButtonContainer)
        bottomControlsView.addSubview(filterSelectionButton)
        
        for recordingModeSelectionButton in recordingModeSelectionButtons {
            bottomControlsView.addSubview(recordingModeSelectionButton)
        }
        
        cameraPreviewContainer.addSubview(filterIntensitySlider)
    }
    
    private func configureViewConstraints() {
        let views: [NSObject : AnyObject] = [
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
        
        let metrics: [NSObject : NSNumber] = [
            "topControlsViewHeight" : 44,
            "filterSelectionViewHeight" : FilterSelectionViewHeight,
            "topControlMargin" : 20,
            "topControlMinWidth" : 44,
            "filterIntensitySliderLeftRightMargin" : 10
        ]
        
        configureSuperviewConstraintsWithMetrics(metrics, views: views)
        configureTopControlsConstraintsWithMetrics(metrics, views: views)
        configureCameraPreviewContainerConstraintsWithMetrics(metrics, views: views)
        configureBottomControlsConstraintsWithMetrics(metrics, views: views)
    }
    
    private func configureSuperviewConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[topControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[cameraPreviewContainer]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomControlsView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: nil, metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][topControlsView(==topControlsViewHeight)]", options: nil, metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomControlsView][filterSelectionView(==filterSelectionViewHeight)]", options: nil, metrics: metrics, views: views))
        
        cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topControlsView, attribute: .Bottom, multiplier: 1, constant: 0)
        cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraints([cameraPreviewContainerTopConstraint!, cameraPreviewContainerBottomConstraint!])
        
        filterSelectionViewConstraint = NSLayoutConstraint(item: filterSelectionController.view, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraint(filterSelectionViewConstraint!)
    }
    
    private func configureTopControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==topControlMargin)-[flashButton(>=topControlMinWidth)]-(>=topControlMargin)-[switchCameraButton(>=topControlMinWidth)]-(==topControlMargin)-|", options: nil, metrics: metrics, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[flashButton]|", options: nil, metrics: nil, views: views))
        topControlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton]|", options: nil, metrics: nil, views: views))
    }
    
    private func configureCameraPreviewContainerConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
        cameraPreviewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: nil, metrics: metrics, views: views))
        cameraPreviewContainer.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .Bottom, relatedBy: .Equal, toItem: cameraPreviewContainer, attribute: .Bottom, multiplier: 1, constant: -20))
    }
    
    private func configureBottomControlsConstraintsWithMetrics(metrics: [NSObject : NSNumber], views: [NSObject : AnyObject]) {
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
            bottomControlsView.addConstraint(NSLayoutConstraint(item: bottomControlsView, attribute: .Top, relatedBy: .Equal, toItem: actionButtonContainer, attribute: .Top, multiplier: 1, constant: 0))
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
        cameraController!.delegate = self
        cameraController!.setup()
        cameraController!.switchToRecordingMode(currentRecordingMode)
    }
    
    private func configureFilterSelectionController() {
        filterSelectionController.selectedBlock = { [weak self] filterType in
            if let cameraController = self?.cameraController where cameraController.effectFilter.filterType != filterType {
                cameraController.effectFilter = IMGLYInstanceFactory.effectFilterWithType(filterType)
                cameraController.effectFilter.inputIntensity = InitialFilterIntensity
                self?.filterIntensitySlider.value = InitialFilterIntensity
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
    
    private func updateViewsForRecordingMode(recordingMode: IMGLYRecordingMode) {
        if let cameraPreviewContainerTopConstraint = cameraPreviewContainerTopConstraint {
            view.removeConstraint(cameraPreviewContainerTopConstraint)
        }
        
        if let cameraPreviewContainerBottomConstraint = cameraPreviewContainerBottomConstraint {
            view.removeConstraint(cameraPreviewContainerBottomConstraint)
        }
        
        
        let color: UIColor
        
        switch recordingMode {
        case .Photo:
            cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topControlsView, attribute: .Bottom, multiplier: 1, constant: 0)
            cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomControlsView, attribute: .Top, multiplier: 1, constant: 0)

            color = UIColor.blackColor()
        case .Video:
            cameraPreviewContainerTopConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
            cameraPreviewContainerBottomConstraint = NSLayoutConstraint(item: cameraPreviewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
            
            color = UIColor.blackColor().colorWithAlphaComponent(0.3)
        }
        
        topControlsView.backgroundColor = color
        bottomControlsView.backgroundColor = color
        filterSelectionController.collectionView?.backgroundColor = color
        
        view.addConstraints([cameraPreviewContainerTopConstraint!, cameraPreviewContainerBottomConstraint!])
    }
    
    private func addActionButtonToContainer(actionButton: UIControl) {
        actionButtonContainer.addSubview(actionButton)
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[actionButton]|", options: nil, metrics: nil, views: [ "actionButton" : actionButton ]))
        actionButtonContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[actionButton]|", options: nil, metrics: nil, views: [ "actionButton" : actionButton ]))
    }
    
    private func updateFlashButton() {
        if let cameraController = cameraController {
            flashButton.hidden = !cameraController.flashAvailable
            
            let bundle = NSBundle(forClass: self.dynamicType)
            
            switch(cameraController.flashMode) {
            case .Auto:
                self.flashButton.setImage(UIImage(named: "flash_auto", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            case .On:
                self.flashButton.setImage(UIImage(named: "flash_on", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            case .Off:
                self.flashButton.setImage(UIImage(named: "flash_off", inBundle: bundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
            }
        } else {
            flashButton.hidden = true
        }
    }
    
    private func resetHideSliderTimer() {
        hideSliderTimer?.invalidate()
        hideSliderTimer = NSTimer.scheduledTimerWithTimeInterval(ShowFilterIntensitySliderInterval, target: self, selector: "hideFilterIntensitySlider:", userInfo: nil, repeats: false)
    }
    
    private func showEditorNavigationControllerWithImage(image: UIImage?) {
        let editorViewController = IMGLYMainEditorViewController()
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
    
    public func setLastImageFromRollAsPreview() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
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
                let currentIndex = find(recordingModes, currentRecordingMode)
                
                if let currentIndex = currentIndex where currentIndex < recordingModes.count - 1 {
                    currentRecordingMode = recordingModes[currentIndex + 1]
                    return
                }
            } else if gestureRecognizer.direction == .Right {
                let currentIndex = find(recordingModes, currentRecordingMode)
                
                if let currentIndex = currentIndex where currentIndex > 0 {
                    currentRecordingMode = recordingModes[currentIndex - 1]
                    return
                }
            }
        }
        
        if let button = sender as? UIButton {
            let buttonIndex = find(recordingModeSelectionButtons, button)
            
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
        cameraController?.selectNextFlashMode()
    }
    
    public func switchCamera(sender: UIButton?) {
        cameraController?.toggleCameraPosition()
    }
    
    public func showCameraRoll(sender: UIButton?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage]
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    public func takePhoto(sender: UIButton?) {
        cameraController?.takePhoto { image, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    if let completionBlock = self.completionBlock {
                        completionBlock(image)
                    } else {
                        self.showEditorNavigationControllerWithImage(image)
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
            
            UIView.animateWithDuration(0.25) {
                // TODO: Handle via callbacks from cameraController?
                if recordVideoButton.recording {
                    self.swipeLeftGestureRecognizer.enabled = false
                    self.swipeRightGestureRecognizer.enabled = false
                    
                    self.cameraRollButton.alpha = 0
                    self.filterSelectionButton.alpha = 0
                    
                    for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                        recordingModeSelectionButton.alpha = 0
                    }
                } else {
                    self.swipeLeftGestureRecognizer.enabled = true
                    self.swipeRightGestureRecognizer.enabled = true
                    
                    self.cameraRollButton.alpha = 1
                    self.filterSelectionButton.alpha = 1
                    
                    for recordingModeSelectionButton in self.recordingModeSelectionButtons {
                        recordingModeSelectionButton.alpha = 1
                    }
                }
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
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: nil, animations: {
                    sender?.transform = CGAffineTransformIdentity
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        self.filterSelectionController.endAppearanceTransition()
                })
            } else {
                // Close
                filterSelectionController.beginAppearanceTransition(false, animated: true)
                filterSelectionViewConstraint.constant = 0
                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: dampingFactor, initialSpringVelocity: 0, options: nil, animations: {
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
}

extension IMGLYCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: {
            if let completionBlock = self.completionBlock {
                completionBlock(image)
            } else {
                self.showEditorNavigationControllerWithImage(image)
            }
        })
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
