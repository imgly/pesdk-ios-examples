//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYCircleGradientView : UIView {
    public var centerPoint = CGPointZero
    public weak var gradientViewDelegate: IMGLYGradientViewDelegate?
    public var controllPoint1 = CGPointZero
    private var controllPoint2_ = CGPointZero
    public var controllPoint2:CGPoint {
        get {
            return controllPoint2_
        }
        set (point) {
            controllPoint2_ = point
            calculateCenterPointFromOtherControlPoints()
            layoutCrosshair()
            setNeedsDisplay()
            if gradientViewDelegate != nil {
                gradientViewDelegate!.controlPointChanged()
            }
        }
    }

    public var normalizedControlPoint1:CGPoint {
        get {
            return CGPointMake(controllPoint1.x / frame.size.width, controllPoint1.y / frame.size.height)
        }
    }

    public var normalizedControlPoint2:CGPoint {
        get {
            return CGPointMake(controllPoint2.x / frame.size.width, controllPoint2.y / frame.size.height)
        }
    }

    private var crossImageView_ = UIImageView()
    private var setup = false

    public override init(frame:CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func commonInit() {
        if setup {
            return
        }
        setup = true

        backgroundColor = UIColor.clearColor()
        configureControlPoints()
        configureCrossImageView()
        configurePanGestureRecognizer()
        configurePinchGestureRecognizer()
    }

    public func configureControlPoints() {
        controllPoint1 = CGPointMake(100,100)
        controllPoint2 = CGPointMake(150,200)
        calculateCenterPointFromOtherControlPoints()
    }

    public func configureCrossImageView() {
        crossImageView_.image = UIImage(named: "crosshair", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
        crossImageView_.userInteractionEnabled = true
        crossImageView_.frame = CGRectMake(0, 0, crossImageView_.image!.size.width, crossImageView_.image!.size.height)
        addSubview(crossImageView_)
    }

    public func configurePanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action:"handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
        crossImageView_.addGestureRecognizer(panGestureRecognizer)
    }

    public func configurePinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action:"handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }

    public func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }

    public override func drawRect(rect:CGRect) {
        let aPath = UIBezierPath(arcCenter: centerPoint, radius: distanceBetweenControlPoints() * 0.5, startAngle: 0,
            endAngle:CGFloat(M_PI * 2.0) , clockwise: true)
        UIColor(white: 0.8, alpha: 1.0).setStroke()
        aPath.closePath()

        let aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        aPath.lineWidth = 1
        aPath.stroke()
        CGContextRestoreGState(aRef)
    }

    public func distanceBetweenControlPoints() -> CGFloat {
        let diffX = controllPoint2.x - controllPoint1.x
        let diffY = controllPoint2.y - controllPoint1.y

        return sqrt(diffX * diffX + diffY  * diffY)
    }

    public func calculateCenterPointFromOtherControlPoints() {
        centerPoint = CGPointMake((controllPoint1.x + controllPoint2.x) / 2.0,
            (controllPoint1.y + controllPoint2.y) / 2.0)
    }

    public func informDeletageAboutRecognizerStates(recognizer recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            if gradientViewDelegate != nil {
                gradientViewDelegate!.userInteractionStarted()
            }
        }
        if recognizer.state == UIGestureRecognizerState.Ended {
            if gradientViewDelegate != nil {
                gradientViewDelegate!.userInteractionEnded()
            }
        }
    }

    public func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(self)
        informDeletageAboutRecognizerStates(recognizer: recognizer)
        let diffX = location.x - centerPoint.x
        let diffY = location.y - centerPoint.y
        controllPoint1 = CGPointMake(controllPoint1.x + diffX, controllPoint1.y + diffY)
        controllPoint2 = CGPointMake(controllPoint2.x + diffX, controllPoint2.y + diffY)
    }

    public func handlePinchGesture(recognizer:UIPinchGestureRecognizer) {
        informDeletageAboutRecognizerStates(recognizer: recognizer)
        if recognizer.numberOfTouches() > 1 {
            controllPoint1 = recognizer.locationOfTouch(0, inView:self)
            controllPoint2 = recognizer.locationOfTouch(1, inView:self)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCrosshair()
        setNeedsDisplay()
    }

    public func layoutCrosshair() {
        crossImageView_.center = centerPoint
    }

    public func centerGUIElements() {
        let x1 = frame.size.width * 0.25
        let x2 = frame.size.width * 0.75
        let y1 = frame.size.height * 0.25
        let y2 = frame.size.height * 0.75
        controllPoint1 = CGPointMake(x1, y1)
        controllPoint2 = CGPointMake(x2, y2)
    }
}
