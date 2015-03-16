//
//  IMGLYTiltShiftDialog.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 19/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public protocol IMGLYFocusDialogViewDelegate {
    func linearButtonPressed()
    func radialButtonPressed()
    func doneButtonPressed()
    func backButtonPressed()
    func offButtonPressed()
}

public class IMGLYFocusDialogView:UIView {
    @IBOutlet public var contentView: UIView!

    @IBOutlet public weak var previewImageView: UIImageView!
    public var delegate:IMGLYFocusDialogViewDelegate? = nil

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - View connection
    public func commonInit() {
        var containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper.loadXib("IMGLYFocusDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        delegate?.backButtonPressed()
    }
    
    @IBAction public func linearButtonPressed(sender: AnyObject) {
        delegate?.linearButtonPressed()
    }
    
    @IBAction public func radialButtonPressed(sender: AnyObject) {
        delegate?.radialButtonPressed()
    }
    
    @IBAction public func offButtonPressed(sender: AnyObject) {
        delegate?.offButtonPressed()
    }
}