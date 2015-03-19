//
//  IMGLYOrientationDialogView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 20/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public protocol IMGLYOrientationDialogViewDelegate: class {
    func rotateLeftButtonPressed()
    func rotateRightButtonPressed()
    func flipHorizontalButtonPressed()
    func flipVerticalButtonPressed()
    func doneButtonPressed()
    func backButtonPressed()
}

public class IMGLYOrientationDialogView: UIView {
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public weak var transperentRectView: UIView!
    
    private weak var delegate_:IMGLYOrientationDialogViewDelegate? = nil
    public weak var delegate:IMGLYOrientationDialogViewDelegate? {
        get {
            return delegate_
        }
        set(delegate) {
            delegate_ = delegate
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - View connection
    public func setup() {
        var containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper.loadXib("IMGLYOrientationDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        delegate?.backButtonPressed()
    }
    
    @IBAction public func rotateLeftButtonPressed(sender: AnyObject) {
        delegate?.rotateLeftButtonPressed()
    }
    
    @IBAction public func rotateRightButtonPressed(sender: AnyObject) {
        delegate?.rotateRightButtonPressed()
    }

    @IBAction public func flipHorizontalButtonPressed(sender: AnyObject) {
        delegate?.flipHorizontalButtonPressed()
    }
    
    @IBAction public func flipVerticalButtonPressed(sender: AnyObject) {
        delegate?.flipVerticalButtonPressed()
    }
}