//
//  IMGLYFocusEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYFocusAction: Int {
    case Off
    case Linear
    case Radial
}

@objc public class IMGLYFocusEditorViewControllerOptions: IMGLYEditorViewControllerOptions {
    
    public typealias IMGLYFocusActionButtonConfigurationClosure = (IMGLYImageCaptionButton, IMGLYFocusAction) -> ()
    
    // MARK: Behaviour
    
    /// Defines all allowed focus actions. The focus buttons are shown in the given order.
    /// Defaults to show all available modes. The .Off action is always added. To set this
    /// property from Obj-C, see the `allowedFocusActionsAsNSNumbers` property.
    public var allowedFocusActions: [IMGLYFocusAction] = [ .Off, .Linear, .Radial ] {
        didSet {
            if !allowedFocusActions.contains(.Off) {
                allowedFocusActions.append(.Off)
            }
        }
    }
    
    /// This closure allows further configuration of the action buttons. The closure is called for
    /// each action button and has the button and its corresponding action as parameters.
    public var actionButtonConfigurationClosure: IMGLYFocusActionButtonConfigurationClosure = { _ in }
    
    // MARK: Obj-C Compatibility
    
    /// An array of `IMGLYFocusAction` raw values wrapped in NSNumbers.
    /// Setting this property overrides any previously set values in
    /// `allowedFocusActions` with the corresponding `IMGLYFocusAction` values.
    public var allowedFocusActionsAsNSNumbers: [NSNumber] = [ IMGLYFocusAction.Off, .Linear, .Radial ].map({ NSNumber(integer: $0.rawValue) }) {
        didSet {
            self.allowedFocusActions = allowedFocusActionsAsNSNumbers.map({ IMGLYFocusAction(rawValue: $0.integerValue)! })
        }
    }
    
    // MARK: Init
    
    public override init() {
        super.init()
        
        /// Override inherited properties with default values
        self.title = NSLocalizedString("focus-editor.title", tableName: nil, bundle: NSBundle(forClass: IMGLYMainEditorViewController.self), value: "", comment: "")
    }
}

public class IMGLYFocusEditorViewController: IMGLYSubEditorViewController {

    // MARK: - Properties
    
    public private(set) lazy var offButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.off", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_off", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "turnOff:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .Off)
        return button
        }()
    
    public private(set) lazy var linearButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.linear", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_linear", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "activateLinear:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .Linear)
        return button
        }()
    
    public private(set) lazy var radialButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.radial", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_radial", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "activateRadial:", forControlEvents: .TouchUpInside)
        self.options.actionButtonConfigurationClosure(button, .Radial)
        return button
        }()
    
    private var selectedButton: IMGLYImageCaptionButton? {
        willSet(newSelectedButton) {
            self.selectedButton?.selected = false
        }
        
        didSet {
            self.selectedButton?.selected = true
        }
    }
    
    private lazy var circleGradientView: IMGLYCircleGradientView = {
        let view = IMGLYCircleGradientView()
        view.gradientViewDelegate = self
        view.hidden = true
        view.alpha = 0
        return view
        }()
    
    private lazy var boxGradientView: IMGLYBoxGradientView = {
        let view = IMGLYBoxGradientView()
        view.gradientViewDelegate = self
        view.hidden = true
        view.alpha = 0
        return view
        }()
    
    // MARK: - IMGLYEditorViewController
    
    public override var options: IMGLYFocusEditorViewControllerOptions {
        return self.configuration.focusEditorViewControllerOptions
    }
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = options.title
        
        configureButtons()
        configureGradientViews()
        
        selectedButton = offButton
        if fixedFilterStack.tiltShiftFilter.tiltShiftType != .Off {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .Off
            updatePreviewImage()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        circleGradientView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
        circleGradientView.centerGUIElements()
        
        boxGradientView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
        boxGradientView.centerGUIElements()
    }
    
    // MARK: - Configuration
    
    private func configureButtons() {
        // Map actions and buttons
        let actionToButtonMap: [IMGLYFocusAction: IMGLYImageCaptionButton] = [
            .Off: offButton,
            .Linear: linearButton,
            .Radial: radialButton
        ]
        
        // Setup button container view
        let buttonContainerView = UIView()
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(buttonContainerView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: [], metrics: nil, views: ["buttonContainerView": buttonContainerView]))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
        
        var views = [String: UIView]()
        var viewNames = [String]()
        for action in options.allowedFocusActions {
            let button = actionToButtonMap[action]!
            let viewName = "_\(String(button.hash))" // View names must start with a letter or underscore
            viewNames.append(viewName)
            buttonContainerView.addSubview(button)
            views[viewName] = button
            buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(viewName)]|", options: [], metrics: nil, views: views))
        }
        
        // Button Constraints
        let visualFormatString = viewNames.reduce("") { (acc, name) -> String in
            return acc + "[\(name)(==buttonWidth)]"
        }
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|\(visualFormatString)|", options: [], metrics: [ "buttonWidth": 90 ], views: views))
    }
    
    private func configureGradientViews() {
        view.addSubview(circleGradientView)
        view.addSubview(boxGradientView)
    }
    
    // MARK: - Actions
    
    @objc private func turnOff(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideBoxGradientView()
        hideCircleGradientView()
        updateFilterTypeAndPreview()
    }
    
    @objc private func activateLinear(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideCircleGradientView()
        showBoxGradientView()
        updateFilterTypeAndPreview()
    }
    
    @objc private func activateRadial(sender: IMGLYImageCaptionButton) {
        if selectedButton == sender {
            return
        }
        
        selectedButton = sender
        hideBoxGradientView()
        showCircleGradientView()
        updateFilterTypeAndPreview()
    }
    
    // MARK: - Helpers
    
    private func updateFilterTypeAndPreview() {
        if selectedButton == linearButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .Box
            fixedFilterStack.tiltShiftFilter.controlPoint1 = boxGradientView.normalizedControlPoint1
            fixedFilterStack.tiltShiftFilter.controlPoint2 = boxGradientView.normalizedControlPoint2
        } else if selectedButton == radialButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .Circle
            fixedFilterStack.tiltShiftFilter.controlPoint1 = circleGradientView.normalizedControlPoint1
            fixedFilterStack.tiltShiftFilter.controlPoint2 = circleGradientView.normalizedControlPoint2
        } else if selectedButton == offButton {
            fixedFilterStack.tiltShiftFilter.tiltShiftType = .Off
        }
        
        updatePreviewImage()
    }
    
    private func showCircleGradientView() {
        circleGradientView.hidden = false
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.circleGradientView.alpha = 1.0
        })
    }
    
    private func hideCircleGradientView() {
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.circleGradientView.alpha = 0.0
            },
            completion: { finished in
                if(finished) {
                    self.circleGradientView.hidden = true
                }
            }
        )
    }
    
    private func showBoxGradientView() {
        boxGradientView.hidden = false
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.boxGradientView.alpha = 1.0
        })
    }
    
    private func hideBoxGradientView() {
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.boxGradientView.alpha = 0.0
            },
            completion: { finished in
                if(finished) {
                    self.boxGradientView.hidden = true
                }
            }
        )
    }

}

extension IMGLYFocusEditorViewController: IMGLYGradientViewDelegate {
    public func userInteractionStarted() {
        fixedFilterStack.tiltShiftFilter.tiltShiftType = .Off
        updatePreviewImage()
    }
    
    public func userInteractionEnded() {
        updateFilterTypeAndPreview()
    }
    
    public func controlPointChanged() {
        
    }
}
