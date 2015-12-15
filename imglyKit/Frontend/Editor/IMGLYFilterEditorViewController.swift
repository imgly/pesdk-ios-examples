//
//  IMGLYFilterEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYFilterEditorViewController: IMGLYSubEditorViewController {
    
    // MARK: - Properties
    
    public let filterSelectionController = IMGLYFilterSelectionController()
    
    public private(set) lazy var filterIntensitySlider: UISlider = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.75
        slider.addTarget(self, action: "changeIntensity:", forControlEvents: .ValueChanged)
        slider.addTarget(self, action: "sliderTouchedUpInside:", forControlEvents: .TouchUpInside)
        
        slider.minimumTrackTintColor = UIColor.whiteColor()
        slider.maximumTrackTintColor = UIColor.whiteColor()
        let sliderThumbImage = UIImage(named: "slider_thumb_image", inBundle: bundle, compatibleWithTraitCollection: nil)
        slider.setThumbImage(sliderThumbImage, forState: .Normal)
        slider.setThumbImage(sliderThumbImage, forState: .Highlighted)
        
        return slider
        }()
    
    private var changeTimer: NSTimer?
    private var updateInterval: NSTimeInterval = 0.01
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("filter-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureFilterSelectionController()
        configureFilterIntensitySlider()
    }
    
    // MARK: - IMGLYEditorViewController
    
    public override var enableZoomingInPreviewImage: Bool {
        return true
    }
    
    // MARK: - Configuration
    
    private func configureFilterSelectionController() {
        filterSelectionController.selectedBlock = { [weak self] filterType, initialFilterIntensity in
            if filterType == .None {
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha > 0 {
                    UIView.animateWithDuration(0.3) {
                        filterIntensitySlider.alpha = 0
                    }
                }
            } else {
                if let filterIntensitySlider = self?.filterIntensitySlider where filterIntensitySlider.alpha < 1 {
                    UIView.animateWithDuration(0.3) {
                        filterIntensitySlider.alpha = 1
                    }
                }
            }
            
            if let fixedFilterStack = self?.fixedFilterStack where filterType != fixedFilterStack.effectFilter.filterType {
                fixedFilterStack.effectFilter = IMGLYInstanceFactory.effectFilterWithType(filterType)
                fixedFilterStack.effectFilter.inputIntensity = initialFilterIntensity
                self?.filterIntensitySlider.value = initialFilterIntensity
            }
            
            self?.updatePreviewImage()
        }
        
        filterSelectionController.activeFilterType = { [weak self] in
            if let fixedFilterStack = self?.fixedFilterStack {
                return fixedFilterStack.effectFilter.filterType
            }
            
            return nil
        }
        
        let views = [ "filterSelectionView" : filterSelectionController.view ]
        
        addChildViewController(filterSelectionController)
        filterSelectionController.didMoveToParentViewController(self)
        bottomContainerView.addSubview(filterSelectionController.view)
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[filterSelectionView]|", options: [], metrics: nil, views: views))
    }
    
    private func configureFilterIntensitySlider() {
        if fixedFilterStack.effectFilter.filterType == .None {
            filterIntensitySlider.alpha = 0
        } else {
            filterIntensitySlider.value = fixedFilterStack.effectFilter.inputIntensity.floatValue
            filterIntensitySlider.alpha = 1
        }
        
        view.addSubview(filterIntensitySlider)
        
        let views: [String : AnyObject] = [
            "filterIntensitySlider" : filterIntensitySlider
        ]
        
        let metrics: [String : AnyObject] = [
            "filterIntensitySliderLeftRightMargin" : 10
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: [], metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .Bottom, relatedBy: .Equal, toItem: previewImageView, attribute: .Bottom, multiplier: 1, constant: -20))
    }
    
    // MARK: - Callbacks
    
    @objc private func changeIntensity(sender: UISlider?) {
        if changeTimer == nil {
            changeTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "update:", userInfo: nil, repeats: false)
        }
    }
    
    @objc private func sliderTouchedUpInside(sender: UISlider?) {
        changeTimer?.invalidate()
        
        fixedFilterStack.effectFilter.inputIntensity = filterIntensitySlider.value
        shouldShowActivityIndicator = false
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
            self.shouldShowActivityIndicator = true
        }
    }
    
    @objc private func update(timer: NSTimer) {
        fixedFilterStack.effectFilter.inputIntensity = filterIntensitySlider.value
        shouldShowActivityIndicator = false
        updatePreviewImageWithCompletion {
            self.changeTimer = nil
            self.shouldShowActivityIndicator = true
        }
    }
    
}
