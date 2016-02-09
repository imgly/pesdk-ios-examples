//
//  StickerCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class StickerCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()

    // MARK: - Initializers

    /**
    Initializes and returns a newly allocated view with the specified frame rectangle.

    - parameter frame: The frame rectangle for the view, measured in points.

    - returns: An initialized view object or `nil` if the object couldn't be created.
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitButton
        configureViews()
    }

    // MARK: - Helpers

    private func configureViews() {
        contentView.addSubview(imageView)

        let views = [
            "imageView" : imageView,
        ]

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|[imageView]|",
            options: [],
            metrics: nil,
            views: views))

        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[imageView]|",
            options: [],
            metrics: nil,
            views: views))
    }
}
