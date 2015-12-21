//
//  IMGLYImageCaptionButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

private let ImageSize = CGSize(width: 36, height: 36)
private let ImageCaptionMargin = 2

public class IMGLYImageCaptionButton: UIControl {

    // MARK: - Properties

    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(11)
        label.textColor = UIColor.whiteColor()
        return label
        }()

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .Center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        }()

    public override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = UIColor(white: 1, alpha: 0.2)
            } else if !selected {
                backgroundColor = UIColor.clearColor()
            }
        }
    }

    public override var selected: Bool {
        didSet {
            if selected {
                backgroundColor = UIColor(white: 1, alpha: 0.2)
            } else if !highlighted {
                backgroundColor = UIColor.clearColor()
            }
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        configureViews()
    }

    // MARK: - Configuration

    private func configureViews() {
        let containerView = UIView()
        containerView.userInteractionEnabled = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        containerView.addSubview(textLabel)
        addSubview(containerView)

        let views = [
            "containerView" : containerView,
            "imageView" : imageView,
            "textLabel" : textLabel
        ]

        let metrics: [ String: AnyObject ] = [
            "imageHeight" : ImageSize.height,
            "imageWidth" : ImageSize.width,
            "imageCaptionMargin" : ImageCaptionMargin
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

        addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    // MARK: - UIView

    public override func sizeThatFits(size: CGSize) -> CGSize {
        return systemLayoutSizeFittingSize(size)
    }

    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

}
