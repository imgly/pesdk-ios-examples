//
//  IMGLYImageCaptionCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYImageCaptionCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .Center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(11)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        containerView.addSubview(textLabel)

        contentView.addSubview(containerView)

        let views = [
            "containerView" : containerView,
            "imageView" : imageView,
            "textLabel" : textLabel
        ]

        let metrics: [ String: AnyObject ] = [
            "imageHeight" : imageSize.height,
            "imageWidth" : imageSize.width,
            "imageCaptionMargin" : imageCaptionMargin
        ]

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-(>=0)-[imageView(==imageWidth)]-(>=0)-|",
            options: [],
            metrics: metrics,
            views: views))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-(>=0)-[textLabel]-(>=0)-|",
            options: [],
            metrics: metrics,
            views: views))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[imageView(==imageHeight)]-(imageCaptionMargin)-[textLabel]|",
            options: .AlignAllCenterX,
            metrics: metrics,
            views: views))

        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    // MARK: - Subclasses

    var imageSize: CGSize {
        // Subclasses should override this
        return CGSizeZero
    }

    var imageCaptionMargin: CGFloat {
        // Subclasses should override this
        return 0
    }

}
