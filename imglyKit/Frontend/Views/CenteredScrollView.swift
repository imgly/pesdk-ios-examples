//
//  CenteredScrollView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 25/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

class CenteredScrollView: UIScrollView {

    private func centerContent() {
        var top = CGFloat(0)
        var left = CGFloat(0)

        if contentSize.width < bounds.width {
            left = (bounds.width - contentSize.width) * 0.5
        }

        if contentSize.height < bounds.height {
            top = (bounds.height - contentSize.height) * 0.5
        }

        contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerContent()
    }

    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        centerContent()
    }

    override var frame: CGRect {
        didSet {
            centerContent()
        }
    }

}
