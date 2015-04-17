//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public struct Line {
    public var start:CGPoint
    public var end:CGPoint
    
    public init(start:CGPoint, end:CGPoint)  {
        self.start = start
        self.end = end
    }
}

@objc(IMGLYBoxGradientView) public class BoxGradientView : UIView {
    public var centerPoint = CGPointZero
    public weak var gradientViewDelegate: GradientViewDelegate?
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
    
    // MARK:- setup
    
    public override init(frame:CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
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
        controllPoint1 = CGPointMake(100,100);
        controllPoint2 = CGPointMake(150,200);
        calculateCenterPointFromOtherControlPoints()
    }
    
    public func configureCrossImageView() {
        crossImageView_.image = UIImage(named: "crosshair", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection:nil)
        crossImageView_.userInteractionEnabled = true
        crossImageView_.frame = CGRectMake(0, 0, crossImageView_.image!.size.width, crossImageView_.image!.size.height)
        addSubview(crossImageView_)
    }
    
    public func configurePanGestureRecognizer() {
        var panGestureRecognizer = UIPanGestureRecognizer(target:self, action:"handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
        crossImageView_.addGestureRecognizer(panGestureRecognizer)
    }
    
    public func configurePinchGestureRecognizer() {
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action:"handlePinchGesture:")
        addGestureRecognizer(pinchGestureRecognizer)
    }
    
    // MARK:- Drawing
    
    public func diagonalLengthOfFrame() -> CGFloat {
        return sqrt(frame.size.width * frame.size.width +
            frame.size.height * frame.size.height)
    }
    
    public func normalizedOrtogonalVector() -> CGPoint {
        var diffX = controllPoint2.x - controllPoint1.x
        var diffY = controllPoint2.y - controllPoint1.y
        
        var diffLength = sqrt(diffX * diffX + diffY  * diffY)
        
        return CGPointMake( -diffY / diffLength, diffX / diffLength)
    }
    
    public func distanceBetweenControlPoints() -> CGFloat {
        var diffX = controllPoint2.x - controllPoint1.x
        var diffY = controllPoint2.y - controllPoint1.y
        
        return sqrt(diffX * diffX + diffY  * diffY)
    }
    
    /*
    This method appears a bit tricky, but its not.
    We just take the vector that connects the control points,
    and rotate it by 90 degrees. Then we normalize it and give it a total
    lenghts that is the lenght of the diagonal, of the Frame.
    That diagonal is the longest line that can be drawn in the Frame, therefore its a good orientation.
    */
    
    public func lineForControlPoint(controlPoint:CGPoint) -> Line {
        var ortogonalVector = normalizedOrtogonalVector()
        var halfDiagonalLengthOfFrame = diagonalLengthOfFrame()
        var scaledOrthogonalVector = CGPointMake(halfDiagonalLengthOfFrame * ortogonalVector.x,
            halfDiagonalLengthOfFrame * ortogonalVector.y)
        var lineStart = CGPointMake(controlPoint.x - scaledOrthogonalVector.x,
            controlPoint.y - scaledOrthogonalVector.y)
        var lineEnd = CGPointMake(controlPoint.x + scaledOrthogonalVector.x,
            controlPoint.y + scaledOrthogonalVector.y)
        return Line(start: lineStart, end: lineEnd);
    }
    
    public func addLineForControlPoint1ToPath(path:UIBezierPath) {
        var line = lineForControlPoint(controllPoint1)
        path.moveToPoint(line.start)
        path.addLineToPoint(line.end)
    }
    
    public func addLineForControlPoint2ToPath(path:UIBezierPath) {
        var line = lineForControlPoint(controllPoint2)
        path.moveToPoint(line.start)
        path.addLineToPoint(line.end)
    }
    
    public override func drawRect(rect: CGRect) {
        var aPath = UIBezierPath()
        UIColor(white: 0.8, alpha: 1.0).setStroke()
        addLineForControlPoint1ToPath(aPath)
        addLineForControlPoint2ToPath(aPath)
        aPath.closePath()
        
        var aRef = UIGraphicsGetCurrentContext()
        CGContextSaveGState(aRef)
        aPath.lineWidth = 1
        aPath.stroke()
        
        CGContextRestoreGState(aRef)
    }
    
    // MARK:- gesture handling
    public func calculateCenterPointFromOtherControlPoints() {
        centerPoint = CGPointMake((controllPoint1.x + controllPoint2.x) / 2.0,
            (controllPoint1.y + controllPoint2.y) / 2.0);
    }
    
    public func informDeletageAboutRecognizerStates(#recognizer:UIGestureRecognizer) {
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
    
    public func handlePanGesture(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(self)
        informDeletageAboutRecognizerStates(recognizer: recognizer)
        var diffX = location.x - centerPoint.x
        var diffY = location.y - centerPoint.y
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
    
    public func isPoint(point:CGPoint, inRect rect:CGRect) -> Bool {
        var top = rect.origin.y
        var bottom = top + rect.size.height
        var left = rect.origin.x
        var right = left + rect.size.width
        var inRectXAxis = point.x > left && point.x < right
        var inRectYAxis = point.y > top && point.y < bottom
        return (inRectXAxis && inRectYAxis)
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
        var x1 = frame.size.width * 0.5
        var x2 = frame.size.width * 0.5
        var y1 = frame.size.height * 0.25
        var y2 = frame.size.height * 0.75
        controllPoint1 = CGPointMake(x1, y1)
        controllPoint2 = CGPointMake(x2, y2)
    }
}
