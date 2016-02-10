//
//  TextLabel.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 22/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

public class TextLabel: UILabel {

    // MARK: - Properties

    public var activateHandler: (() -> Void)?
    public var decrementHandler: (() -> Void)?
    public var incrementHandler: (() -> Void)?
    public var rotateLeftHandler: (() -> Void)?
    public var rotateRightHandler: (() -> Void)?
    public var changeTextHandler: (() -> Void)?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isAccessibilityElement = true
        accessibilityHint = Localize("Double-tap and hold to move")

        let rotateLeftAction = UIAccessibilityCustomAction(name: Localize("Rotate left"), target: self, selector: "rotateLeft")
        let rotateRightAction = UIAccessibilityCustomAction(name: Localize("Rotate right"), target: self, selector: "rotateRight")
        let changeAction = UIAccessibilityCustomAction(name: Localize("Change text"), target: self, selector: "changeText")
        accessibilityCustomActions = [rotateLeftAction, rotateRightAction, changeAction]
    }

    // MARK: - Accessibility

    public override func accessibilityActivate() -> Bool {
        activateHandler?()
        return true
    }

    override public func accessibilityDecrement() {
        decrementHandler?()
    }

    override public func accessibilityIncrement() {
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

    @objc private func changeText() -> Bool {
        changeTextHandler?()
        return true
    }
}
