//
//  IMGLYFilterDialog.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYFilterDialogViewDelegate {
    func doneButtonPressed()
    func backButtonPressed()
}

public protocol IMGLYSliderDialogViewDelegate : IMGLYFilterDialogViewDelegate {
    func sliderValueChanged(newValue:Float)
}

public class IMGLYFilterDialogView: UIView {
    private var containerViewHelper_:IMGLYContainerViewHelper?
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public weak var filterSelectorView: IMGLYFilterSelectorView!
    
    public var activeFilterType:IMGLYFilterType {
        get {
            if filterSelectorView != nil {
                return filterSelectorView.activeFilterType
            }
            return IMGLYFilterType.None
        }
        set (filterType) {
            filterSelectorView?.activeFilterType = filterType
        }
    }
    
    public var delegate:IMGLYFilterDialogViewDelegate? {
        get {
            return delegate_
        }
        set(delegate) {
            delegate_ = delegate
        }
    }
    
    private var delegate_:IMGLYFilterDialogViewDelegate? = nil
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

   
    // MARK: - View connection
    public func setup() {
        containerViewHelper_ = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper_?.loadXib("IMGLYFilterDialogView", view:self)
        containerViewHelper_?.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
    }
    
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        self.delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }
}
