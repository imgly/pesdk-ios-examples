//
//  IMGLYVideoRecordButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 26/06/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public final class IMGLYVideoRecordButton: UIControl {

    // MARK: - Properties

    static let lineWidth = CGFloat(2)
    static let recordingColor = UIColor(red:0.94, green:0.27, blue:0.25, alpha:1)
    public var recording = false {
        didSet {
            updateInnerLayer()
        }
    }

    private lazy var outerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.whiteColor().CGColor
        layer.lineWidth = lineWidth
        layer.fillColor = UIColor.clearColor().CGColor
        return layer
        }()

    private lazy var innerLayer: IMGLYShapeLayer = {
        let layer = IMGLYShapeLayer()
        layer.fillColor = recordingColor.CGColor
        return layer
        }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.addSublayer(outerLayer)
        layer.addSublayer(innerLayer)
    }

    // MARK: - Helpers

    private func updateOuterLayer() {
        let outerRect = bounds.insetBy(dx: IMGLYVideoRecordButton.lineWidth, dy: IMGLYVideoRecordButton.lineWidth)
        outerLayer.frame = bounds
        outerLayer.path = UIBezierPath(ovalInRect: outerRect).CGPath
    }

    private func updateInnerLayer() {
        if recording {
            let innerRect = bounds.insetBy(dx: 0.3 * bounds.size.width, dy: 0.3 * bounds.size.height)
            innerLayer.frame = bounds
            innerLayer.path = UIBezierPath(roundedRect: innerRect, cornerRadius: 4).CGPath
        } else {
            let innerRect = bounds.insetBy(dx: IMGLYVideoRecordButton.lineWidth * 2.5, dy: IMGLYVideoRecordButton.lineWidth * 2.5)
            innerLayer.frame = bounds
            innerLayer.path = UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.size.width / 2).CGPath
        }
    }

    // MARK: - UIView

    override public func layoutSubviews() {
        super.layoutSubviews()

        updateOuterLayer()
        updateInnerLayer()
    }

    // MARK: - UIControl

    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        if !innerLayer.containsPoint(location) {
            return false
        }

        innerLayer.fillColor = IMGLYVideoRecordButton.recordingColor.colorWithAlphaComponent(0.3).CGColor
        return true
    }

    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        recording = !recording
        innerLayer.fillColor = IMGLYVideoRecordButton.recordingColor.CGColor
        sendActionsForControlEvents(.TouchUpInside)
    }

    public override func cancelTrackingWithEvent(event: UIEvent?) {
        innerLayer.fillColor = IMGLYVideoRecordButton.recordingColor.CGColor
    }
}
