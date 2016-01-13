//
//  UIViewExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

private var associatedObjectKey: Int = 0

extension UIView {
    private var associatedConstraints: [String: [NSLayoutConstraint]] {
        get {
            return objc_getAssociatedObject(self, &associatedObjectKey) as? [String: [NSLayoutConstraint]] ?? [String: [NSLayoutConstraint]]()
        }

        set {
            objc_setAssociatedObject(self, &associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func hasConstraintForKey(key: String) -> Bool {
        if let constraints = associatedConstraints[key] {
            return constraints.count != 0 ? true : false
        }

        return false
    }

    func addConstraint(constraint: NSLayoutConstraint, forKey key: String) {
        addConstraints([constraint], forKey: key)
    }

    func addConstraints(constraints: [NSLayoutConstraint], forKey key: String) {
        if constraints.count == 0 {
            return
        }

        var constraintStorage = associatedConstraints[key]
        if constraintStorage == nil {
            constraintStorage = [NSLayoutConstraint]()
        }

        constraintStorage?.appendContentsOf(constraints)
        addConstraints(constraints)
        associatedConstraints[key] = constraintStorage
    }

    func removeAllConstraintsForKey(key: String) {
        if let constraints = associatedConstraints[key] {
            removeConstraints(constraints)
            associatedConstraints[key] = nil
        }
    }

    func clearAllConstraintsForKey(key: String) {
        associatedConstraints[key] = nil
    }

    func constraintsForKey(key: String) -> [NSLayoutConstraint]? {
        return associatedConstraints[key]
    }
}
