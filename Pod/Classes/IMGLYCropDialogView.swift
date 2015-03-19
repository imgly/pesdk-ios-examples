//
//  IMGLYCropDialogView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc public protocol IMGLYCropDialogViewDelegate: class {
    func doneButtonPressed()
    func backButtonPressed()
    func ratio1to1ButtonPressed()
    func ratio4to3ButtonPressed()
    func ratio16to9ButtonPressed()
    func ratioFreeButtonPressed()
}

public class IMGLYCropDialogView: UIView {
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public weak var transperentRectView: UIView!
    @IBOutlet public weak var customRatioHighlight: UIView!
    @IBOutlet public weak var oneToOneRatioHighlight: UIView!
    @IBOutlet public weak var fourToThreeRatioHighlight: UIView!
    @IBOutlet public weak var sixteenToNineRatioHighlight: UIView!
    
    
    private weak var delegate_:IMGLYCropDialogViewDelegate? = nil
    public weak var delegate:IMGLYCropDialogViewDelegate? {
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
        containerViewHelper.loadXib("IMGLYCropDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        delegate?.doneButtonPressed()
    }
    
    @IBAction public func ratio16to9ButtonPressed(sender: AnyObject) {
        sixteenToNineRatioHighlight.hidden = false
        oneToOneRatioHighlight.hidden = true
        fourToThreeRatioHighlight.hidden = true
        customRatioHighlight.hidden = true
        delegate?.ratio16to9ButtonPressed()
    }
    
    @IBAction public func ratio4to3ButtonPressed(sender: AnyObject) {
        sixteenToNineRatioHighlight.hidden = true
        oneToOneRatioHighlight.hidden = true
        fourToThreeRatioHighlight.hidden = false
        customRatioHighlight.hidden = true
        delegate?.ratio4to3ButtonPressed()
    }

    @IBAction public func ratio1to1ButtonPressed(sender: AnyObject) {
        sixteenToNineRatioHighlight.hidden = true
        oneToOneRatioHighlight.hidden = false
        fourToThreeRatioHighlight.hidden = true
        customRatioHighlight.hidden = true
        delegate?.ratio1to1ButtonPressed()
    }
    
    @IBAction public func ratioFreeButtonPressed(sender: AnyObject) {
        sixteenToNineRatioHighlight.hidden = true
        oneToOneRatioHighlight.hidden = true
        fourToThreeRatioHighlight.hidden = true
        customRatioHighlight.hidden = false
        delegate?.ratioFreeButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }
}