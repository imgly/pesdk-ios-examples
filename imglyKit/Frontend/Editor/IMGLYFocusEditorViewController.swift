//
//  IMGLYFocusEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYFocusEditorViewController: IMGLYSubEditorViewController {

    // MARK: - Properties
    
    public private(set) lazy var offButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.off", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_off", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "turnOff:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var linearButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.linear", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_linear", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateLinear:", forControlEvents: .TouchUpInside)
        return button
        }()
    
    public private(set) lazy var radialButton: IMGLYImageCaptionButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = IMGLYImageCaptionButton()
        button.textLabel.text = NSLocalizedString("focus-editor.radial", tableName: nil, bundle: bundle, value: "", comment: "")
        button.imageView.image = UIImage(named: "icon_focus_radial", inBundle: bundle, compatibleWithTraitCollection: nil)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.addTarget(self, action: "activateRadial:", forControlEvents: .TouchUpInside)
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
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("focus-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
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
        let buttonContainerView = UIView()
        buttonContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomContainerView.addSubview(buttonContainerView)
        
        buttonContainerView.addSubview(offButton)
        buttonContainerView.addSubview(linearButton)
        buttonContainerView.addSubview(radialButton)
        
        let views = [
            "buttonContainerView" : buttonContainerView,
            "offButton" : offButton,
            "linearButton" : linearButton,
            "radialButton" : radialButton
        ]
        
        let metrics = [
            "buttonWidth" : 90
        ]
        
        // Button Constraints
        
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[offButton(==buttonWidth)][linearButton(==offButton)][radialButton(==offButton)]|", options: nil, metrics: metrics, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[offButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[linearButton]|", options: nil, metrics: nil, views: views))
        buttonContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[radialButton]|", options: nil, metrics: nil, views: views))
        
        // Container Constraints
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[buttonContainerView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: bottomContainerView, attribute: .CenterX, multiplier: 1, constant: 0))
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
