//
//  PullableView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 27/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//
import UIKit
import AVFoundation

@objc(IMGLYPullableViewDelegate) public protocol PullableViewDelegate {
    func pullableView(pView: PullableView, didChangeState opend: Bool)
}

@objc(IMGLYPullableView) public class PullableView: UIView {
    var closedCenter = CGPoint(x: 0, y: 0)
    var openedCenter = CGPoint(x: 0, y: 0)
    var handleView = UIView()
    var dragRecognizer = UIPanGestureRecognizer()
    var tapRecognizer = UITapGestureRecognizer()
    var startPos = CGPoint(x: 0, y: 0)
    var minPos = CGPoint(x: 0, y: 0)
    var maxPos = CGPoint(x: 0, y: 0)
    var opened = false
    var verticalAxis = false
    var toggleOnTap: Bool {
        set {
            tapRecognizer.enabled = newValue
        }
        get {
            return tapRecognizer.enabled
        }
    }
    var animate = true
    var animationDuration: Double = 0.0
    weak var delegate: PullableViewDelegate?

    public  override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func commonInit() {
        animate = true
        animationDuration = 0.2
        toggleOnTap = true
        // Creates the handle view. Subclasses should resize, reposition and style this view
        handleView = UIView(frame: CGRect(x:0, y:frame.size.height - 40, width:frame.size.width, height:40))
        self.addSubview(handleView)
        dragRecognizer = UIPanGestureRecognizer(target: self, action: "handleDrag:")
        dragRecognizer.minimumNumberOfTouches = 1
        dragRecognizer.maximumNumberOfTouches = 1
        handleView.addGestureRecognizer(dragRecognizer)
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        handleView.addGestureRecognizer(tapRecognizer)
        opened = false
    }

    func handleDrag(sender: UIPanGestureRecognizer) {
        if sender.state == .Began {
            startPos = self.center
            // Determines if the view can be pulled in the x or y axis
            verticalAxis = closedCenter.x == openedCenter.x
            // Finds the minimum and maximum points in the axis
            if verticalAxis {
                minPos = closedCenter.y < openedCenter.y ? closedCenter : openedCenter
                maxPos = closedCenter.y > openedCenter.y ? closedCenter : openedCenter
            } else {
                minPos = closedCenter.x < openedCenter.x ? closedCenter : openedCenter
                maxPos = closedCenter.x > openedCenter.x ? closedCenter : openedCenter
            }
        } else if sender.state == .Changed {
            var translate: CGPoint = sender.translationInView(self.superview)
            var newPos: CGPoint
            // Moves the view, keeping it constrained between openedCenter and closedCenter
            if verticalAxis {
                newPos = CGPoint(x: startPos.x, y: startPos.y + translate.y)
                if newPos.y < minPos.y {
                    newPos.y = minPos.y
                    translate = CGPoint(x: 0, y: newPos.y - startPos.y)
                }
                if newPos.y > maxPos.y {
                    newPos.y = maxPos.y
                    translate = CGPoint(x: 0, y: newPos.y - startPos.y)
                }
            } else {
                newPos = CGPoint(x: startPos.x + translate.x, y: startPos.y)
                if newPos.x < minPos.x {
                    newPos.x = minPos.x
                    translate = CGPoint(x: newPos.x - startPos.x, y: 0)
                }
                if newPos.x > maxPos.x {
                    newPos.x = maxPos.x
                    translate = CGPoint(x: newPos.x - startPos.x, y: 0)
                }
            }
            sender.setTranslation(translate, inView: self.superview)
            self.center = newPos
        } else if sender.state == .Ended {
            // Gets the velocity of the gesture in the axis, so it can be
            // determined to which endpoint the state should be set.
            let vectorVelocity: CGPoint = sender.velocityInView(self.superview)
            let axisVelocity: CGFloat = verticalAxis ? vectorVelocity.y : vectorVelocity.x
            let target: CGPoint = axisVelocity < 0 ? minPos : maxPos
            let op: Bool = CGPointEqualToPoint(target, openedCenter)
            self.setOpened(op, animated: animate)
        }

    }

    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.setOpened(!opened, animated: animate)
        }
    }

   func setOpened(opend: Bool, animated anim: Bool) {
        self.opened = opend
        if anim {
            UIView.animateWithDuration(1.0,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                },
                completion: { finished in
                    if finished {
                        // Restores interaction after the animation is over
                        self.dragRecognizer.enabled = true
                        self.tapRecognizer.enabled = self.toggleOnTap
                        self.delegate?.pullableView(self, didChangeState: self.opened)
                    }
            })
        }
        self.center = opened ? openedCenter : closedCenter
        if anim {
            // For the duration of the animation, no further interaction with the view is permitted
            dragRecognizer.enabled = false
            tapRecognizer.enabled = false
            UIView.commitAnimations()
        } else {
            delegate?.pullableView(self, didChangeState: opened)
        }
    }
}
