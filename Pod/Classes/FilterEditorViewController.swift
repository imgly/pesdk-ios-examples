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
        
        let bundle = NSBundle(forClass: EditorViewController.self)
        navigationItem.title = NSLocalizedString("filter-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        filterSelectionController.selectedBlock = { [unowned self] filter in
            self.fixedFilterStack.effectFilter = filter
            self.updatePreviewImage()
        }
        
        filterSelectionController.activeFilter = { [unowned self] in
            return self.fixedFilterStack.effectFilter
        }
        
        let views = [ "filterSelectionView" : filterSelectionController.filterSelectionView ]
        bottomContainerView.addSubview(filterSelectionController.filterSelectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[filterSelectionView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[filterSelectionView]|", options: nil, metrics: nil, views: views))
    }
    
}
