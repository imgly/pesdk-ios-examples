//
//  IMGLYCropRectComponent.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 23/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYCropRectComponent {
    public var cropRect = CGRectZero

    private var topLineView_ = UIView(frame: CGRectZero)
    private var bottomLineView_ = UIView(frame: CGRectZero)
    private var leftLineView_ = UIView(frame: CGRectZero)
    private var rightLineView_ = UIView(frame: CGRectZero)

    public var topLeftAnchor_: UIImageView?
    public var topRightAnchor_: UIImageView?
    public var bottomLeftAnchor_: UIImageView?
    public var bottomRightAnchor_: UIImageView?
    private var transparentView_: UIView?
    private var parentView_: UIView?
    private var showAnchors_ = true

    // call this in viewDidLoad
    public func setup(transparentView: UIView, parentView: UIView, showAnchors: Bool) {
        transparentView_ = transparentView
        parentView_ = parentView
        showAnchors_ = showAnchors
        setupLineViews()
        setupAnchors()
    }

    // call this in viewDidAppear
    public func present() {
        layoutViewsForCropRect()
        showViews()
    }

    private func setupLineViews() {
        cropRect = CGRect(x: 100, y: 100, width: 150, height: 100)
        setupLineView(topLineView_)
        setupLineView(bottomLineView_)
        setupLineView(leftLineView_)
        setupLineView(rightLineView_)
    }

    private func setupLineView(lineView: UIView) {
        lineView.backgroundColor = UIColor.whiteColor()
        lineView.hidden = true
        parentView_!.addSubview(lineView)
    }

    private func addMaskRectView() {
        let bounds = CGRect(x: 0, y: 0, width: transparentView_!.frame.size.width,
            height: transparentView_!.frame.size.height)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.fillColor = UIColor.blackColor().CGColor
        let path = UIBezierPath(rect: cropRect)
        path.appendPath(UIBezierPath(rect: bounds))
        maskLayer.path = path.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd

       transparentView_!.layer.mask = maskLayer
    }

    private func setupAnchors() {
        let anchorImage = UIImage(named: "crop_anchor", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
        topLeftAnchor_ = createAnchorWithImage(anchorImage)
        topRightAnchor_ = createAnchorWithImage(anchorImage)
        bottomLeftAnchor_ = createAnchorWithImage(anchorImage)
        bottomRightAnchor_ = createAnchorWithImage(anchorImage)
    }

    private func createAnchorWithImage(image: UIImage?) -> UIImageView {
        let anchor = UIImageView(image: image!)
        anchor.contentMode = UIViewContentMode.Center
        anchor.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        anchor.hidden = true
        transparentView_!.addSubview(anchor)
        return anchor
    }

    // MARK:- layout
    public func layoutViewsForCropRect() {
        layoutLines()
        layoutAnchors()
        addMaskRectView()
    }

    private func layoutLines() {
        let left = cropRect.origin.x + transparentView_!.frame.origin.x
        let right = left + cropRect.size.width - 1.0
        let top = cropRect.origin.y + transparentView_!.frame.origin.y
        let bottom = top + cropRect.size.height - 1.0
        let width = cropRect.size.width
        let height = cropRect.size.height

        leftLineView_.frame = CGRect(x: left, y: top, width: 1, height: height)
        rightLineView_.frame = CGRect(x: right, y: top, width: 1, height: height)
        topLineView_.frame = CGRect(x: left, y: top, width: width, height: 1)
        bottomLineView_.frame = CGRect(x: left, y: bottom, width: width, height: 1)
    }

    private func layoutAnchors() {
        let left = cropRect.origin.x
        let right = left + cropRect.size.width
        let top = cropRect.origin.y
        let bottom = top + cropRect.size.height
        topLeftAnchor_!.center = CGPoint(x: left, y: top)
        topRightAnchor_!.center = CGPoint(x: right, y: top)
        bottomLeftAnchor_!.center = CGPoint(x: left, y: bottom)
        bottomRightAnchor_!.center = CGPoint(x: right, y: bottom)
    }

    public func showViews() {
        if showAnchors_ {
            topLeftAnchor_!.hidden = false
            topRightAnchor_!.hidden = false
            bottomLeftAnchor_!.hidden = false
            bottomRightAnchor_!.hidden = false
        }
        leftLineView_.hidden = false
        rightLineView_.hidden = false
        topLineView_.hidden = false
        bottomLineView_.hidden = false
    }
}
