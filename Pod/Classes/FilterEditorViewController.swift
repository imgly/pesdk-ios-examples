//
//  FilterEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYFilterEditorViewController) public class FilterEditorViewController: SubEditorViewController {
    
    // MARK: - Properties
    
    public let filterSelectionController = FilterSelectionController()
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("filter-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        filterSelectionController.selectedBlock = { [unowned self] filterType in
            self.fixedFilterStack.effectFilter = InstanceFactory.sharedInstance.effectFilterWithType(filterType)
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
    
}
