//
//  IMGLYTextDialogView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public protocol IMGLYTextDialogViewDelegate {
    func doneButtonPressed()
    func backButtonPressed()
    func selectedColor(color:UIColor)
}

public class IMGLYTextDialogView: UIView, IMGLYTextColorSelectorViewDelegate {
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public weak var colorSelectorView: IMGLYTextColorSelectorView!
    
    private var delegate_:IMGLYTextDialogViewDelegate? = nil
    public var delegate:IMGLYTextDialogViewDelegate? {
        get {
            return delegate_
        }
        set(delegate) {
            delegate_ = delegate
        }
    }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - View connection
    private func commonInit() {
        var containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper.loadXib("IMGLYTextDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
        self.colorSelectorView.menuDelegate = self
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        self.delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }
    
    public func selectedColor(color:UIColor) {
        self.delegate?.selectedColor(color)
    }
}
