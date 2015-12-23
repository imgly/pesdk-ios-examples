//
//  IMGLYFilterCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYFilterCollectionViewCell: IMGLYImageCaptionCollectionViewCell {

    // MARK: - Properties

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()

    lazy var tickImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .Center
        imageView.alpha = 0
        imageView.image = UIImage(named: "icon_tick", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
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

    // MARK: - Configuration
    func showTick() {
        tickImageView.alpha = 1
        imageView.alpha = 0.4
    }

    func hideTick() {
        tickImageView.alpha = 0
        imageView.alpha = 1
    }

    // MARK: - Helpers

    private func configureViews() {
        imageView.addSubview(activityIndicator)
        imageView.addSubview(tickImageView)

        let views = [
            "tickImageView" : tickImageView
        ]

        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[tickImageView]|", options: [], metrics: nil, views: views))
        imageView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tickImageView]|", options: [], metrics: nil, views: views))

        imageView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0))
        imageView.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: imageView, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    // MARK: - ImageCaptionCollectionViewCell

    override var imageSize: CGSize {
        return CGSize(width: 56, height: 56)
    }

    override var imageCaptionMargin: CGFloat {
        return 3
    }
}
