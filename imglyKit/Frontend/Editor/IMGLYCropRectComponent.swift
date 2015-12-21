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

    private var topLineView_:UIView = UIView(frame: CGRectZero)
    private var bottomLineView_:UIView = UIView(frame: CGRectZero)
    private var leftLineView_:UIView = UIView(frame: CGRectZero)
    private var rightLineView_:UIView = UIView(frame: CGRectZero)

    public var topLeftAnchor_:UIImageView?
    public var topRightAnchor_:UIImageView?
    public var bottomLeftAnchor_:UIImageView?
    public var bottomRightAnchor_:UIImageView?
    private var transparentView_:UIView?
    private var parentView_:UIView?
    private var showAnchors_ = true

    // call this in viewDidLoad
    public func setup(transparentView:UIView, parentView:UIView, showAnchors:Bool) {
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
        cropRect = CGRectMake(100, 100, 150, 100)
        setupLineView(topLineView_)
        setupLineView(bottomLineView_)
        setupLineView(leftLineView_)
        setupLineView(rightLineView_)
    }

    private func setupLineView(lineView:UIView) {
        lineView.backgroundColor = UIColor.whiteColor()
        lineView.hidden = true
        parentView_!.addSubview(lineView)
    }

    private func addMaskRectView() {
        let bounds = CGRectMake(0, 0, transparentView_!.frame.size.width,
            transparentView_!.frame.size.height)

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

    private func createAnchorWithImage(image:UIImage?) -> UIImageView {
        let anchor = UIImageView(image: image!)
        anchor.contentMode = UIViewContentMode.Center
        anchor.frame = CGRectMake(0, 0, 44, 44)
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

        leftLineView_.frame = CGRectMake(left, top, 1, height)
        rightLineView_.frame = CGRectMake(right, top, 1, height)
        topLineView_.frame = CGRectMake(left, top, width, 1)
        bottomLineView_.frame = CGRectMake(left, bottom, width, 1)
    }

    private func layoutAnchors() {
        let left = cropRect.origin.x
        let right = left + cropRect.size.width
        let top = cropRect.origin.y
        let bottom = top + cropRect.size.height
        topLeftAnchor_!.center = CGPointMake(left, top)
        topRightAnchor_!.center = CGPointMake(right, top)
        bottomLeftAnchor_!.center = CGPointMake(left, bottom)
        bottomRightAnchor_!.center = CGPointMake(right, bottom)
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
