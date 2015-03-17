//
//  IMGLYBrightnessDialogView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYOneSliderDialogView: UIView {
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var previewImageView: UIImageView!
    @IBOutlet public weak var slider_: UISlider!
    @IBOutlet public weak var navigationItem:UINavigationItem!
    private var changeTimer: NSTimer?
    private var updateInterval: NSTimeInterval = 0.1
    
    private weak var delegate_:IMGLYSliderDialogViewDelegate? = nil
    public weak var delegate:IMGLYSliderDialogViewDelegate? {
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
        containerViewHelper.loadXib("IMGLYOneSliderDialogView", view:self)
        containerViewHelper.addContentViewAndSetupConstraints(hostView: self, contentView: self.contentView)
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        self.delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }

    @IBAction public func sliderValueChanged(sender: AnyObject) {
        if changeTimer == nil {
            changeTimer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: "notifyDelegateAndDeleteTimer:", userInfo: nil, repeats: false)
        }
    }
    
    public func notifyDelegateAndDeleteTimer(notification: NSNotification) {
        self.delegate?.sliderValueChanged(slider_.value)
        changeTimer = nil
    }
}