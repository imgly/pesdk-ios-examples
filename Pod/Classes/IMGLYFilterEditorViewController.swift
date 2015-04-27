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
        let slider = UISlider()
        slider.setTranslatesAutoresizingMaskIntoConstraints(false)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: "changeIntensity:", forControlEvents: .ValueChanged)
        return slider
        }()
    
    private var changeTimer: NSTimer?
    private var updateInterval: NSTimeInterval = 0.1
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("filter-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureFilterSelectionController()
        configureFilterIntensitySlider()
    }
    
    // MARK: - Configuration
    
    private func configureFilterSelectionController() {
        filterSelectionController.selectedBlock = { [unowned self] filterType in
            self.fixedFilterStack.effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(filterType)
            
            if filterType == .None {
                if self.filterIntensitySlider.alpha > 0 {
                    UIView.animateWithDuration(0.3) {
                        self.filterIntensitySlider.alpha = 0
                    }
                }
            } else {
                if self.filterIntensitySlider.alpha < 1 {
                    UIView.animateWithDuration(0.3) {
                        self.filterIntensitySlider.alpha = 1
                    }
                }
                
                self.fixedFilterStack.effectFilter.inputIntensity = InitialFilterIntensity
                self.filterIntensitySlider.value = InitialFilterIntensity
            }
            
            self.updatePreviewImage()
        }
        
        filterSelectionController.activeFilterType = { [unowned self] in
            return self.fixedFilterStack.effectFilter.filterType
        }
        
        let views = [ "filterSelectionView" : filterSelectionController.view ]
        
        addChildViewController(filterSelectionController)
        filterSelectionController.didMoveToParentViewController(self)
        bottomContainerView.addSubview(filterSelectionController.view)
        
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[filterSelectionView]|", options: nil, metrics: nil, views: views))
    }
    
    private func configureFilterIntensitySlider() {
        if fixedFilterStack.effectFilter.filterType == .None {
            filterIntensitySlider.alpha = 0
        } else {
            filterIntensitySlider.value = fixedFilterStack.effectFilter.inputIntensity.floatValue
            filterIntensitySlider.alpha = 1
        }
        
        view.addSubview(filterIntensitySlider)
        
        let views: [NSObject : AnyObject] = [
            "filterIntensitySlider" : filterIntensitySlider
        ]
        
        let metrics: [NSObject : NSNumber] = [
            "filterIntensitySliderLeftRightMargin" : 20
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-(==filterIntensitySliderLeftRightMargin)-[filterIntensitySlider]-(==filterIntensitySliderLeftRightMargin)-|", options: nil, metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: filterIntensitySlider, attribute: .Bottom, relatedBy: .Equal, toItem: previewImageView, attribute: .Bottom, multiplier: 1, constant: -20))
    }
    
    // MARK: - Callbacks
    
    @objc private func changeIntensity(sender: UISlider?) {
        if changeTimer == nil {
            changeTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "update:", userInfo: nil, repeats: false)
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
