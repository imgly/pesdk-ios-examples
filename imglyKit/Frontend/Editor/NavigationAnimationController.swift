//
//  IMGLYNavigationAnimationController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

class IMGLYNavigationAnimationController: NSObject {
}

extension IMGLYNavigationAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

        if let fromViewController = fromViewController, let toViewController = toViewController {
            let toView = toViewController.view
            let fromView = fromViewController.view

            let containerView = transitionContext.containerView()
            containerView?.addSubview(toView)
            containerView?.sendSubviewToBack(toView)

            let duration = transitionDuration(transitionContext)
            UIView.animateWithDuration(duration, animations: {
                fromView.alpha = 0
                }, completion: { finished in
                    if transitionContext.transitionWasCancelled() {
                        fromView.alpha = 1
                    } else {
                        fromView.removeFromSuperview()
                        fromView.alpha = 1
                    }

                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
