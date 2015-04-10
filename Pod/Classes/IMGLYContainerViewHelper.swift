//
//  IMGLYConstraintHelper.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public class IMGLYContainerViewHelper {
    // MARK: - View connection
    public func loadXib(name:String, view:UIView) {
        NSBundle(forClass: self.dynamicType).loadNibNamed(name, owner: view, options: nil)
    }
    
    public func addContentViewAndSetupConstraints(#hostView:UIView, contentView:UIView) {
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        hostView.addSubview(contentView)
        setupContraintsForContentView(contentView, hostView: hostView)
    }
    
    public func setupContraintsForContentView(contentView:UIView, hostView:UIView) {
        addEdgeConstraint(NSLayoutAttribute.Left, superview: hostView, subview: contentView)
        addEdgeConstraint(NSLayoutAttribute.Right, superview: hostView, subview: contentView)
        addEdgeConstraint(NSLayoutAttribute.Top, superview: hostView, subview: contentView)
        addEdgeConstraint(NSLayoutAttribute.Bottom, superview: hostView, subview: contentView)
    }
    
    private func addEdgeConstraint(edge:NSLayoutAttribute, superview:UIView, subview:UIView) {
        var constraint = NSLayoutConstraint(item: subview, attribute: edge, relatedBy: NSLayoutRelation.Equal,
            toItem: superview, attribute: edge, multiplier: 1, constant: 0)
        superview.addConstraints([constraint])
    }
}