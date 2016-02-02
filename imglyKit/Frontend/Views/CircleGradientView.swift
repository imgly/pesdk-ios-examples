//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYCircleGradientView) public class CircleGradientView: UIView {
    public var centerPoint = CGPoint.zero
    public weak var gradientViewDelegate: GradientViewDelegate?
    public var controlPoint1 = CGPoint.zero
    public var controlPoint2 = CGPoint.zero {
        didSet {
            calculateCenterPointFromOtherControlPoints()
            layoutCrosshair()
            setNeedsDisplay()
            gradientViewDelegate?.controlPointChanged()
        }
    }

    public var normalizedControlPoint1: CGPoint {
        return CGPoint(x: controlPoint1.x / frame.size.width, y: controlPoint1.y / frame.size.height)
    }

    public var normalizedControlPoint2: CGPoint {
        return CGPoint(x: controlPoint2.x / frame.size.width, y: controlPoint2.y / frame.size.height)
    }

    private var crossImageView = UIImageView()
    private var setup = false

    public override init(frame: CGRect) {
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
        controlPoint1 = CGPoint(x: 100, y: 100)
        controlPoint2 = CGPoint(x: 150, y: 200)
        calculateCenterPointFromOtherControlPoints()
    }

    public func configureCrossImageView() {
        crossImageView.image = UIImage(named: "crosshair", inBundle: NSBundle(forClass: CircleGradientView.self), compatibleWithTraitCollection:nil)
        crossImageView.userInteractionEnabled = true
        crossImageView.frame = CGRect(x: 0, y: 0, width: crossImageView.image!.size.width, height: crossImageView.image!.size.height)
        addSubview(crossImageView)
    }

    public func configurePanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action:"handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
        crossImageView.addGestureRecognizer(panGestureRecognizer)
    }

    public func configurePinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action:"handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }

    public func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }

    public override func drawRect(rect: CGRect) {
        let aPath = UIBezierPath(arcCenter: centerPoint, radius: distanceBetweenControlPoints() * 0.5, startAngle: 0,
            endAngle:CGFloat(M_PI * 2.0), clockwise: true)
        UIColor(white: 0.8, alpha: 1.0).setStroke()
        aPath.closePath()

        let aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        aPath.lineWidth = 1
        aPath.stroke()
        CGContextRestoreGState(aRef)
    }

    public func distanceBetweenControlPoints() -> CGFloat {
        let diffX = controlPoint2.x - controlPoint1.x
        let diffY = controlPoint2.y - controlPoint1.y

        return sqrt(diffX * diffX + diffY  * diffY)
    }

    public func calculateCenterPointFromOtherControlPoints() {
        centerPoint = CGPoint(x: (controlPoint1.x + controlPoint2.x) / 2.0,
            y: (controlPoint1.y + controlPoint2.y) / 2.0)
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
        controlPoint1 = CGPoint(x: controlPoint1.x + diffX, y: controlPoint1.y + diffY)
        controlPoint2 = CGPoint(x: controlPoint2.x + diffX, y: controlPoint2.y + diffY)
    }

    public func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        informDeletageAboutRecognizerStates(recognizer: recognizer)
        if recognizer.numberOfTouches() > 1 {
            controlPoint1 = recognizer.locationOfTouch(0, inView:self)
            controlPoint2 = recognizer.locationOfTouch(1, inView:self)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCrosshair()
        setNeedsDisplay()
    }

    public func layoutCrosshair() {
        crossImageView.center = centerPoint
    }

    public func centerGUIElements() {
        let x1 = frame.size.width * 0.25
        let x2 = frame.size.width * 0.75
        let y1 = frame.size.height * 0.25
        let y2 = frame.size.height * 0.75
        controlPoint1 = CGPoint(x: x1, y: y1)
        controlPoint2 = CGPoint(x: x2, y: y2)
    }
}
