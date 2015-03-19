//
//  IMGLYEditorMainDialog.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 06/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYMainMenuButtonType: Int {
    case Magic,
    Filter,
    Orientation,
    Focus,
    Crop,
    Brightness,
    Contrast,
    Saturation,
    Noise,
    Text,
    Reset
}
    
@objc public protocol IMGLYEditorMainDialogViewDelegate: class {
    func menuButtonPressed(buttonType:IMGLYMainMenuButtonType)
    func doneButtonPressed()
    func backButtonPressed()
}

public class IMGLYEditorMainDialogView: UIView {

    public weak var delegate:IMGLYEditorMainDialogViewDelegate? {
        get {
            return delegate_
        }
        set(delegate) {
            delegate_ = delegate
        }
    }
    
    private weak var delegate_:IMGLYEditorMainDialogViewDelegate? = nil
    private var buttonMap_:[UIButton:IMGLYMainMenuButtonType] = [:]
    
    @IBOutlet public weak var scrollView_: UIScrollView!
    @IBOutlet public var contentView: UIView!
    @IBOutlet public weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet public weak var magicButton_: UIButton!
    @IBOutlet public weak var orientationButton_: UIButton!
    @IBOutlet public weak var focusButton_: UIButton!
    @IBOutlet public weak var cropButton_: UIButton!
    @IBOutlet public weak var brightnessButton_: UIButton!
    @IBOutlet public weak var contrastButton_: UIButton!
    @IBOutlet public weak var saturationButton_: UIButton!
    @IBOutlet public weak var textButton_: UIButton!
    @IBOutlet public weak var filterButton_: UIButton!
    @IBOutlet public weak var imagePreview: UIImageView!
    
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
        NSBundle(forClass: IMGLYEditorMainDialogView.self).loadNibNamed("IMGLYEditorMainDialogView", owner: self, options: nil)
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.contentView)
        self.addEdgeConstraint(NSLayoutAttribute.Left, superview: self, subview: self.contentView)
        self.addEdgeConstraint(NSLayoutAttribute.Right, superview: self, subview: self.contentView)
        self.addEdgeConstraint(NSLayoutAttribute.Top, superview: self, subview: self.contentView)
        self.addEdgeConstraint(NSLayoutAttribute.Bottom, superview: self, subview: self.contentView)
        setupButtonMap()
    }
    
    public func setupButtonMap() {
        buttonMap_ = [magicButton_:IMGLYMainMenuButtonType.Magic,
            filterButton_:IMGLYMainMenuButtonType.Filter,
            orientationButton_:IMGLYMainMenuButtonType.Orientation,
            focusButton_:IMGLYMainMenuButtonType.Focus,
            cropButton_:IMGLYMainMenuButtonType.Crop,
            brightnessButton_:IMGLYMainMenuButtonType.Brightness,
            contrastButton_:IMGLYMainMenuButtonType.Contrast,
            saturationButton_:IMGLYMainMenuButtonType.Saturation,
            textButton_:IMGLYMainMenuButtonType.Text]
    }
    
    public func addEdgeConstraint(edge:NSLayoutAttribute, superview:UIView, subview:UIView) {
        var constraint = NSLayoutConstraint(item: subview, attribute: edge, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: edge, multiplier: 1, constant: 0)
        superview.addConstraints([constraint])
    }
    
    @IBAction public func doneButtonPressed(sender: AnyObject) {
        self.delegate?.doneButtonPressed()
    }
    
    @IBAction public func backButtonPressed(sender: AnyObject) {
        self.delegate?.backButtonPressed()
    }
    
    @IBAction public func menuButtonPressed(sender: AnyObject) {
        let button = sender as! UIButton
        let type = buttonMap_[button]
        
        if type == .Magic {
            button.selected = !button.selected
        }
        
        if delegate != nil {
            delegate!.menuButtonPressed(type!)
        }
    }
}
