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
//    var closedCenter = CGPoint(x: 0, y: 0)
//    var openedCenter = CGPoint(x: 0, y: 0)
    var marginConstraint: NSLayoutConstraint?
    var openedMargin = CGFloat(100)
    var closedMargin = CGFloat(400)
    public var handleView = UIView()
    var dragRecognizer = UIPanGestureRecognizer()
    var tapRecognizer = UITapGestureRecognizer()
    var startPos = CGPoint(x: 0, y: 0)
    var minPos = CGFloat(0)
    var maxPos = CGFloat(0)
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
            minPos = closedMargin < openedMargin ? closedMargin : openedMargin
            maxPos = closedMargin > openedMargin ? closedMargin : openedMargin

        } else if sender.state == .Changed {
            var translate: CGPoint = sender.translationInView(self.superview)
            var newPos = CGPoint(x: startPos.x, y: startPos.y + translate.y)
            if newPos.y < minPos {
                newPos.y = minPos
                translate = CGPoint(x: 0, y: newPos.y - startPos.y)
            }
            if newPos.y > maxPos {
                newPos.y = maxPos
                translate = CGPoint(x: 0, y: newPos.y - startPos.y)
            }
        sender.setTranslation(translate, inView: self.superview)
            self.center = newPos
        } else if sender.state == .Ended {
            // Gets the velocity of the gesture in the axis, so it can be
            // determined to which endpoint the state should be set.
            let vectorVelocity = sender.velocityInView(self.superview)
            let axisVelocity = vectorVelocity.y
            let target = axisVelocity < 0 ? minPos : maxPos
            //let op: Bool = CGPointEqualToPoint(target, openedCenter)
            let op = target == openedMargin
            self.setOpened(op, animated: animate)
        }
    }

    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.setOpened(!opened, animated: animate)
        }
    }
/*

    self.heightFromTop.constant = 550.0f;
    [myView setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.25f animations:^{
    [myView layoutIfNeeded];
    }];
*/
   func setOpened(opend: Bool, animated anim: Bool) {
        guard let marginConstraint = self.marginConstraint else {
            return
        }
        self.opened = opend
        // For the duration of the animation, no further interaction with the view is permitted
        dragRecognizer.enabled = false
        tapRecognizer.enabled = false
        marginConstraint.constant = opend ? self.openedMargin : self.closedMargin
        self.needsUpdateConstraints()
        UIView.animateWithDuration(animationDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.layoutIfNeeded()
            },
            completion: { finished in
                if finished {
                    // Restores interaction after the animation is over
                    self.dragRecognizer.enabled = true
                    self.tapRecognizer.enabled = true
                    self.delegate?.pullableView(self, didChangeState: self.opened)
                }
        })
    }
}
