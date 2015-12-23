//
//  AnimationDelegate.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 11/05/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import QuartzCore

public typealias AnimationDelegateBlock = (Bool) -> (Void)

public class AnimationDelegate: NSObject {

    // MARK: - Properties

    public let block: AnimationDelegateBlock

    // MARK: - Initializers

    init(block: AnimationDelegateBlock) {
        self.block = block
    }

    // MARK: - Animation Delegate

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        block(flag)
    }
}
