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
    public var marginConstraint: NSLayoutConstraint?
    public var openedMargin = CGFloat(0)
    public var closedMargin = CGFloat(800)
    public var handleView = UIView()
    public var opened = false
    public let handleHeight = CGFloat(20)

    private var dragRecognizer = UIPanGestureRecognizer()
    private var tapRecognizer = UITapGestureRecognizer()
    private var startPos = CGPoint(x: 0, y: 0)
    private var minPos = CGFloat(0)
    private var maxPos = CGFloat(0)

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
        configureHandleView()
        // Creates the handle view. Subclasses should resize, reposition and style this view
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

    private func configureHandleView() {
        handleView = UIView(frame: CGRect(x:0, y:0, width:frame.size.width, height:handleHeight))
        handleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(handleView)

        let views = [
            "handleView" : handleView
        ]
        handleView.backgroundColor = UIColor.blueColor()
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[handleView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[handleView(==\(handleHeight))]", options: [], metrics: nil, views: views))
    }

    @objc func handleDrag(sender: UIPanGestureRecognizer) {
        guard let marginConstraint = self.marginConstraint else {
            return
        }
        if sender.state == .Began {
            startPos = CGPoint(x: self.center.x, y: marginConstraint.constant)
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
            marginConstraint.constant = newPos.y
        } else if sender.state == .Ended {
            // Gets the velocity of the gesture in the axis, so it can be
            // determined to which endpoint the state should be set.
            let vectorVelocity = sender.velocityInView(self.superview)
            let axisVelocity = vectorVelocity.y
            let target = axisVelocity < 0 ? minPos : maxPos
            let opened = target == openedMargin
            self.setOpened(opened, animated: animate)
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.setOpened(!opened, animated: animate)
        }
    }

    func setOpened(opened: Bool, animated anim: Bool) {
        guard let marginConstraint = self.marginConstraint else {
            return
        }
        self.opened = opened
        // For the duration of the animation, no further interaction with the view is permitted
        dragRecognizer.enabled = false
        tapRecognizer.enabled = false
        marginConstraint.constant = opened ? self.openedMargin : self.closedMargin
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
