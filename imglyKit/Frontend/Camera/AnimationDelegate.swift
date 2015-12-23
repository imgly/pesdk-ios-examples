//
//  IMGLYAnimationDelegate.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import QuartzCore

public typealias IMGLYAnimationDelegateBlock = (Bool) -> (Void)

public class IMGLYAnimationDelegate: NSObject {

    // MARK: - Properties

    public let block: IMGLYAnimationDelegateBlock

    // MARK: - Initializers

    init(block: IMGLYAnimationDelegateBlock) {
        self.block = block
    }

    // MARK: - Animation Delegate

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        block(flag)
    }
}
