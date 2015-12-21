//
//  IMGLYStickerCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYStickerCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
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
