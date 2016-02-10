//
//  StickerImageView.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

public class StickerImageView: UIImageView {

    // MARK: - Properties

    public var decrementHandler: (() -> Void)?
    public var incrementHandler: (() -> Void)?
    public var rotateLeftHandler: (() -> Void)?
    public var rotateRightHandler: (() -> Void)?

    // MARK: - Initializers

    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        userInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityTraits &= ~UIAccessibilityTraitImage
        accessibilityTraits |= UIAccessibilityTraitAdjustable
        accessibilityHint = Localize("Double-tap and hold to move")

        let rotateLeftAction = UIAccessibilityCustomAction(name: Localize("Rotate left"), target: self, selector: "rotateLeft")
        let rotateRightAction = UIAccessibilityCustomAction(name: Localize("Rotate right"), target: self, selector: "rotateRight")
        accessibilityCustomActions = [rotateLeftAction, rotateRightAction]
    }

    public override func accessibilityDecrement() {
        decrementHandler?()
    }

    public override func accessibilityIncrement() {
        incrementHandler?()
    }

    @objc private func rotateLeft() -> Bool {
        rotateLeftHandler?()
        return true
    }

    @objc private func rotateRight() -> Bool {
        rotateRightHandler?()
        return true
    }
}
