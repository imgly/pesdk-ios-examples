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

    private var topLineView = UIView(frame: CGRectZero)
    private var bottomLineView = UIView(frame: CGRectZero)
    private var leftLineView = UIView(frame: CGRectZero)
    private var rightLineView = UIView(frame: CGRectZero)

    public var topLeftAnchor: UIImageView?
    public var topRightAnchor: UIImageView?
    public var bottomLeftAnchor: UIImageView?
    public var bottomRightAnchor: UIImageView?
    private var transparentView: UIView?
    private var parentView: UIView?
    private var showAnchors = true

    // call this in viewDidLoad
    public func setup(transparentView: UIView, parentView: UIView, showAnchors: Bool) {
        self.transparentView = transparentView
        self.parentView = parentView
        self.showAnchors = showAnchors
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
        setupLineView(topLineView)
        setupLineView(bottomLineView)
        setupLineView(leftLineView)
        setupLineView(rightLineView)
    }

    private func setupLineView(lineView: UIView) {
        lineView.backgroundColor = UIColor.whiteColor()
        lineView.hidden = true
        parentView!.addSubview(lineView)
    }

    private func addMaskRectView() {
        let bounds = CGRect(x: 0, y: 0, width: transparentView!.frame.size.width,
            height: transparentView!.frame.size.height)

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.fillColor = UIColor.blackColor().CGColor
        let path = UIBezierPath(rect: cropRect)
        path.appendPath(UIBezierPath(rect: bounds))
        maskLayer.path = path.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd

       transparentView!.layer.mask = maskLayer
    }

    private func setupAnchors() {
        let anchorImage = UIImage(named: "crop_anchor", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
        topLeftAnchor = createAnchorWithImage(anchorImage)
        topRightAnchor = createAnchorWithImage(anchorImage)
        bottomLeftAnchor = createAnchorWithImage(anchorImage)
        bottomRightAnchor = createAnchorWithImage(anchorImage)
    }

    private func createAnchorWithImage(image: UIImage?) -> UIImageView {
        let anchor = UIImageView(image: image!)
        anchor.contentMode = UIViewContentMode.Center
        anchor.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        anchor.hidden = true
        transparentView!.addSubview(anchor)
        return anchor
    }

    // MARK:- layout
    public func layoutViewsForCropRect() {
        layoutLines()
        layoutAnchors()
        addMaskRectView()
    }

    private func layoutLines() {
        let left = cropRect.origin.x + transparentView!.frame.origin.x
        let right = left + cropRect.size.width - 1.0
        let top = cropRect.origin.y + transparentView!.frame.origin.y
        let bottom = top + cropRect.size.height - 1.0
        let width = cropRect.size.width
        let height = cropRect.size.height

        leftLineView.frame = CGRect(x: left, y: top, width: 1, height: height)
        rightLineView.frame = CGRect(x: right, y: top, width: 1, height: height)
        topLineView.frame = CGRect(x: left, y: top, width: width, height: 1)
        bottomLineView.frame = CGRect(x: left, y: bottom, width: width, height: 1)
    }

    private func layoutAnchors() {
        let left = cropRect.origin.x
        let right = left + cropRect.size.width
        let top = cropRect.origin.y
        let bottom = top + cropRect.size.height
        topLeftAnchor!.center = CGPoint(x: left, y: top)
        topRightAnchor!.center = CGPoint(x: right, y: top)
        bottomLeftAnchor!.center = CGPoint(x: left, y: bottom)
        bottomRightAnchor!.center = CGPoint(x: right, y: bottom)
    }

    public func showViews() {
        if showAnchors {
            topLeftAnchor!.hidden = false
            topRightAnchor!.hidden = false
            bottomLeftAnchor!.hidden = false
            bottomRightAnchor!.hidden = false
        }

        leftLineView.hidden = false
        rightLineView.hidden = false
        topLineView.hidden = false
        bottomLineView.hidden = false
    }
}
