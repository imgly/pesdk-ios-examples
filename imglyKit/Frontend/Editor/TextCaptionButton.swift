//
//  TextCaptionButton.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 04/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

private let kImageSize = CGSize(width: 36, height: 36)
private let kImageCaptionMargin = 2

@objc(IMGLYTextCaptionButton) public class TextCaptionButton: UIControl {

    // MARK: - Properties

    public private(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(11)
        label.textColor = UIColor.whiteColor()
        return label
    }()

    public private(set) lazy var titleView: UILabel = {
        let titleView = UILabel()
        titleView.contentMode = .Center
        titleView.textAlignment = .Center
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
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

    public var fontSize = CGFloat(20) {
        didSet {
            updateButtonFont()
        }
    }

    public var fontName = "" {
        didSet {
            updateButtonFont()
        }
    }

    private var titleViewTopConstraint = NSLayoutConstraint()

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
        let titleViewContainerView = UIView()
        let containerView = UIView()
        containerView.userInteractionEnabled = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleViewContainerView)
        containerView.addSubview(textLabel)
        addSubview(containerView)
        titleViewContainerView.addSubview(titleView)
        titleViewContainerView.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "containerView" : containerView,
            "titleView" : titleView,
            "textLabel" : textLabel,
            "titleViewContainerView" : titleViewContainerView
        ]

        let metrics: [ String: AnyObject ] = [
            "imageHeight" : kImageSize.height,
            "imageWidth" : kImageSize.width,
            "imageCaptionMargin" : kImageCaptionMargin
        ]

        titleViewContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-[titleView]-|",
            options: [],
            metrics: metrics,
            views: views))

        titleViewContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[titleView]",
            options: [],
            metrics: metrics,
            views: views))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-[titleViewContainerView]-|",
            options: [],
            metrics: metrics,
            views: views))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "|-(>=0)-[textLabel]-(>=0)-|",
            options: [],
            metrics: metrics,
            views: views))

        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[titleViewContainerView(==imageHeight)]-(imageCaptionMargin)-[textLabel]|",
            options: .AlignAllCenterX,
            metrics: metrics,
            views: views))

        titleViewTopConstraint = NSLayoutConstraint(item: titleView, attribute: .Top, relatedBy: .Equal, toItem: titleViewContainerView, attribute: .Top, multiplier: 1, constant: 0)
        titleViewContainerView.addConstraint(titleViewTopConstraint)

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

    private func updateButtonFont() {
        if fontName.characters.count > 0 {
            titleView.font = UIFont(name: fontName, size: fontSize)
            titleView.sizeToFit()
            let textSize = titleView.text!.sizeWithAttributes([ NSFontAttributeName: titleView.font])
            contentHorizontalAlignment = .Center
            contentVerticalAlignment = .Top
            let topPadding = titleView.font.ascender - titleView.font.capHeight
            let offset =  -textSize.height / 2.0 + kImageSize.height * 0.5 - topPadding * 0.5
            titleViewTopConstraint.constant = offset
        }
    }
}
