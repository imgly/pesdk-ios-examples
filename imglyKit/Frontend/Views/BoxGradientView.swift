//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public struct Line {
    public let start: CGPoint
    public let end: CGPoint
}

/**
 *  This class represents the box gradient view. It is used within the focus editor view controller
 *  to visualize the choosen focus parameters. Basicaly a box shaped area is left unblured.
 *  Two controlpoints define the upper and lower midpoint of that box. Therefore they determin the rotation,
 *  position and size of the box.
 */
@objc(IMGLYBoxGradientView) public class BoxGradientView: UIView {
    /// This delegate is used to propergate changes of the view.
    public weak var gradientViewDelegate: GradientViewDelegate?

    /// The center point of the box.
    public var centerPoint = CGPoint.zero

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
        get {
            return CGPoint(x: controlPoint1.x / frame.size.width, y: controlPoint1.y / frame.size.height)
        }
    }

    /// The normalized second control point.
    public var normalizedControlPoint2: CGPoint {
        get {
            return CGPoint(x: controlPoint2.x / frame.size.width, y: controlPoint2.y / frame.size.height)
        }
    }

    private var crossImageView = UIImageView()
    private var setup = false

    // MARK: - setup

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
        accessibilityLabel = Localize("Linear focus area")
        accessibilityHint = Localize("Double-tap and hold to move focus area")

        let rotateLeftAction = UIAccessibilityCustomAction(name: Localize("Rotate left"), target: self, selector: "rotateLeft")
        let rotateRightAction = UIAccessibilityCustomAction(name: Localize("Rotate right"), target: self, selector: "rotateRight")
        accessibilityCustomActions = [rotateLeftAction, rotateRightAction]
    }

    private func configureControlPoints() {
        controlPoint1 = CGPoint(x: 100, y: 100)
        controlPoint2 = CGPoint(x: 150, y: 200)
        calculateCenterPointFromOtherControlPoints()
    }

    private func configureCrossImageView() {
        crossImageView.image = UIImage(named: "crosshair", inBundle: NSBundle(forClass: BoxGradientView.self), compatibleWithTraitCollection:nil)
        crossImageView.userInteractionEnabled = true
        crossImageView.frame = CGRect(x: 0, y: 0, width: crossImageView.image!.size.width, height: crossImageView.image!.size.height)
        addSubview(crossImageView)
    }

    private func configurePanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target:self, action:"handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
        crossImageView.addGestureRecognizer(panGestureRecognizer)
    }

    private func configurePinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action:"handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }

    // MARK: - drawing

    private func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }

    private func normalizedOrtogonalVector() -> CGPoint {
        let diffX = controlPoint2.x - controlPoint1.x
        let diffY = controlPoint2.y - controlPoint1.y

        let diffLength = sqrt(diffX * diffX + diffY  * diffY)

        return CGPoint(x: -diffY / diffLength, y: diffX / diffLength)
    }

    private func distanceBetweenControlPoints() -> CGFloat {
        let diffX = controlPoint2.x - controlPoint1.x
        let diffY = controlPoint2.y - controlPoint1.y

        return sqrt(diffX * diffX + diffY  * diffY)
    }

    /*
    This method appears a bit tricky, but its not.
    We just take the vector that connects the control points,
    and rotate it by 90 degrees. Then we normalize it and give it a total
    lenghts that is the lenght of the diagonal, of the Frame.
    That diagonal is the longest line that can be drawn in the Frame, therefore its a good orientation.
    */

    private func lineForControlPoint(controlPoint: CGPoint) -> Line {
        let ortogonalVector = normalizedOrtogonalVector()
        let halfDiagonalLengthOfFrame = diagonalLengthOfFrame()
        let scaledOrthogonalVector = CGPoint(x: halfDiagonalLengthOfFrame * ortogonalVector.x,
            y: halfDiagonalLengthOfFrame * ortogonalVector.y)
        let lineStart = CGPoint(x: controlPoint.x - scaledOrthogonalVector.x,
            y: controlPoint.y - scaledOrthogonalVector.y)
        let lineEnd = CGPoint(x: controlPoint.x + scaledOrthogonalVector.x,
            y: controlPoint.y + scaledOrthogonalVector.y)
        return Line(start: lineStart, end: lineEnd)
    }

    private func addLineForControlPoint1ToPath(path: UIBezierPath) {
        let line = lineForControlPoint(controlPoint1)
        path.moveToPoint(line.start)
        path.addLineToPoint(line.end)
    }

    private func addLineForControlPoint2ToPath(path: UIBezierPath) {
        let line = lineForControlPoint(controlPoint2)
        path.moveToPoint(line.start)
        path.addLineToPoint(line.end)
    }

    /**
     Draws the receiver’s image within the passed-in rectangle.

     - parameter rect: The portion of the view’s bounds that needs to be updated.
     */
    public override func drawRect(rect: CGRect) {
        let aPath = UIBezierPath()
        UIColor(white: 0.8, alpha: 1.0).setStroke()
        addLineForControlPoint1ToPath(aPath)
        addLineForControlPoint2ToPath(aPath)
        aPath.closePath()

        aPath.lineWidth = 1
        aPath.stroke()
    }

    // MARK: - gesture handling
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
        if recognizer.state == UIGestureRecognizerState.Ended ||
            recognizer.state == UIGestureRecognizerState.Cancelled {
                if gradientViewDelegate != nil {
                    gradientViewDelegate!.userInteractionEnded()
                }
        }
    }

    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(self)
        informDeletageAboutRecognizerStates(recognizer: recognizer)
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

    private func isPoint(point: CGPoint, inRect rect: CGRect) -> Bool {
        let top = rect.origin.y
        let bottom = top + rect.size.height
        let left = rect.origin.x
        let right = left + rect.size.width
        let inRectXAxis = point.x > left && point.x < right
        let inRectYAxis = point.y > top && point.y < bottom
        return (inRectXAxis && inRectYAxis)
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

        let line1 = lineForControlPoint(controlPoint1)
        let line2 = lineForControlPoint(controlPoint2)

        if let frame = CGRect(points: [line1.start, line1.end, line2.start, line2.end]) {
            accessibilityFrame = convertRect(frame, toView: nil)
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
        }
    }

    public func centerGUIElements() {
        let x1 = frame.size.width * 0.5
        let x2 = frame.size.width * 0.5
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

    @objc private func rotateLeft() -> Bool {
        // Move control points by -10 degrees around centerPoint

        // Calculate angle of new point
        let angle1 = angleOfPoint(controlPoint1, onCircleAroundCenter: centerPoint) - CGFloat(10 * M_PI / 180)
        let angle2 = angleOfPoint(controlPoint2, onCircleAroundCenter: centerPoint) - CGFloat(10 * M_PI / 180)

        // Calculate vector
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1)
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2)

        // Calculate radius
        let radius1 = sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy)
        let radius2 = sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy)

        // Calculate points
        controlPoint1 = CGPoint(x: radius1 * cos(angle1) + centerPoint.x, y: radius1 * sin(angle1) + centerPoint.y)
        controlPoint2 = CGPoint(x: radius2 * cos(angle2) + centerPoint.x, y: radius2 * sin(angle2) + centerPoint.y)
        return true
    }

    @objc private func rotateRight() -> Bool {
        // Move control points by +10 degrees around centerPoint

        // Calculate angle of new point
        let angle1 = angleOfPoint(controlPoint1, onCircleAroundCenter: centerPoint) + CGFloat(10 * M_PI / 180)
        let angle2 = angleOfPoint(controlPoint2, onCircleAroundCenter: centerPoint) + CGFloat(10 * M_PI / 180)

        // Calculate vector
        let vector1 = CGVector(startPoint: centerPoint, endPoint: controlPoint1)
        let vector2 = CGVector(startPoint: centerPoint, endPoint: controlPoint2)

        // Calculate radius
        let radius1 = sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy)
        let radius2 = sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy)

        // Calculate points
        controlPoint1 = CGPoint(x: radius1 * cos(angle1) + centerPoint.x, y: radius1 * sin(angle1) + centerPoint.y)
        controlPoint2 = CGPoint(x: radius2 * cos(angle2) + centerPoint.x, y: radius2 * sin(angle2) + centerPoint.y)
        return true
    }

    private func angleOfPoint(point: CGPoint, onCircleAroundCenter center: CGPoint) -> CGFloat {
        return atan2(point.y - center.y, point.x - center.x)
    }
}
