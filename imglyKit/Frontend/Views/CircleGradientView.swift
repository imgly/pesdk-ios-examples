//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/**
 This class represents the circle gradient view. It is used within the focus editor view controller
 to visualize the choosen focus parameters. Basicaly a circle shaped area is left unblured.
 Two controlpoints define two opposing points on the border of the induced circle. Therefore they determin the rotation,
 position and size of the circle.
 */
@objc(IMGLYCircleGradientView) public class CircleGradientView: UIView {

    /// :nodoc:
    public var centerPoint = CGPoint.zero

    /// The receiver’s delegate.
    /// seealso: `GradientViewDelegate`.
    public weak var gradientViewDelegate: GradientViewDelegate?

    ///  The first control point.
    public var controlPoint1 = CGPoint.zero

    /// The second control point.
    public var controlPoint2 = CGPoint.zero {
        didSet {
            calculateCenterPointFromOtherControlPoints()
            layoutCrosshair()
            setNeedsDisplay()
            gradientViewDelegate?.controlPointChanged()
        }
    }

    /// The normalized first control point.
    public var normalizedControlPoint1: CGPoint {
        return CGPoint(x: controlPoint1.x / frame.size.width, y: controlPoint1.y / frame.size.height)
    }

    /// The normalized second control point.
    public var normalizedControlPoint2: CGPoint {
        return CGPoint(x: controlPoint2.x / frame.size.width, y: controlPoint2.y / frame.size.height)
    }

    private var crossImageView = UIImageView()
    private var setup = false

    /**
     Initializes and returns a newly allocated view with the specified frame rectangle.

     - parameter frame: The frame rectangle for the view, measured in points.

     - returns: An initialized view object or `nil` if the object couldn't be created.
     */
    public override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        if setup {
            return
        }
        setup = true

        backgroundColor = UIColor.clearColor()
        configureControlPoints()
        configureCrossImageView()
        configurePanGestureRecognizer()
        configurePinchGestureRecognizer()

        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitAdjustable
        accessibilityLabel = Localize("Radial focus area")
        accessibilityHint = Localize("Double-tap and hold to move focus area")
    }

    public func configureControlPoints() {
        controlPoint1 = CGPoint(x: 150, y: 100)
        controlPoint2 = CGPoint(x: 150, y: 200)
        calculateCenterPointFromOtherControlPoints()
    }

    private func configureCrossImageView() {
        crossImageView.image = UIImage(named: "crosshair", inBundle: NSBundle(forClass: CircleGradientView.self), compatibleWithTraitCollection:nil)
        crossImageView.userInteractionEnabled = true
        crossImageView.frame = CGRect(x: 0, y: 0, width: crossImageView.image!.size.width, height: crossImageView.image!.size.height)
        addSubview(crossImageView)
    }

    public func configurePanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
        crossImageView.addGestureRecognizer(panGestureRecognizer)
    }

    public func configurePinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }

    private func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }

    /**
     Draws the receiver’s image within the passed-in rectangle.

     - parameter rect: The portion of the view’s bounds that needs to be updated.
     */
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

    private func distanceBetweenControlPoints() -> CGFloat {
        let diffX = controlPoint2.x - controlPoint1.x
        let diffY = controlPoint2.y - controlPoint1.y

        return sqrt(diffX * diffX + diffY  * diffY)
    }

    private func calculateCenterPointFromOtherControlPoints() {
        centerPoint = CGPoint(x: (controlPoint1.x + controlPoint2.x) / 2.0,
            y: (controlPoint1.y + controlPoint2.y) / 2.0)
    }

    private func informDeletageAboutRecognizerStates(recognizer recognizer: UIGestureRecognizer) {
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

    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(self)
        informDelegateAboutRecognizerStates(recognizer: recognizer)
        let diffX = location.x - centerPoint.x
        let diffY = location.y - centerPoint.y
        controlPoint1 = CGPoint(x: controlPoint1.x + diffX, y: controlPoint1.y + diffY)
        controlPoint2 = CGPoint(x: controlPoint2.x + diffX, y: controlPoint2.y + diffY)
    }

    @objc private func handlePinchGesture(recognizer: UIPinchGestureRecognizer) {
        informDeletageAboutRecognizerStates(recognizer: recognizer)
        if recognizer.numberOfTouches() > 1 {
            controlPoint1 = recognizer.locationOfTouch(0, inView:self)
            controlPoint2 = recognizer.locationOfTouch(1, inView:self)
        }
    }

    /**
     Lays out subviews.
     */
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCrosshair()
        setNeedsDisplay()
    }

    private func layoutCrosshair() {
        crossImageView.center = centerPoint

        let distance = distanceBetweenControlPoints()
        accessibilityFrame = convertRect(CGRect(x: centerPoint.x - distance / 2, y: centerPoint.y - distance / 2, width: distance, height: distance), toView: nil)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }

    /**
     Centers the ui-elements within the views frame.
     */
    public func centerGUIElements() {
        let x1 = frame.size.width * 0.25
        let x2 = frame.size.width * 0.75
        let y1 = frame.size.height * 0.25
        let y2 = frame.size.height * 0.75
        controlPoint1 = CGPoint(x: x1, y: y1)
        controlPoint2 = CGPoint(x: x2, y: y2)
    }

    // MARK: - Accessibility

    public override func accessibilityIncrement() {
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1).normalizedVector()
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2).normalizedVector()

        // Widen gap by 20 points
        controlPoint1 = controlPoint1 + 10 * vector1
        controlPoint2 = controlPoint2 + 10 * vector2
    }

    public override func accessibilityDecrement() {
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1).normalizedVector()
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2).normalizedVector()

        // Reduce gap by 20 points
        controlPoint1 = controlPoint1 - 10 * vector1
        controlPoint2 = controlPoint2 - 10 * vector2
    }
}
