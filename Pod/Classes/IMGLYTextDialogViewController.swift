//
//  IMGLYTextDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTextDialogViewController: UIViewController, IMGLYSubEditorViewControllerProtocol,
IMGLYTextDialogViewDelegate, IMGLYFontSelectorDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private let kEditorMenuViewHeight_ = CGFloat(95)
    private let kTextInputHeight_ = CGFloat(40.0)
    private let kMinimumFontSize_ = CGFloat(12.0)
    private let kTextLabelInitialMargin_ = CGFloat(40.0)
    private let kFontSizeInTextInput_ = CGFloat(20.0)
    
    private var dialogView_:IMGLYTextDialogView?
    private var filtredImage_:UIImage? = nil
    private var textInput_:UITextField? = nil
    private var textColor_:UIColor = UIColor.whiteColor()
    private var textLabelClipView_:UIView? = nil
    private var textLabel_:UILabel? = nil
    private var fontSelector_:IMGLYFontSelector? = nil
    private var keyboardSize_ = CGSizeZero
    private var panOffset_ = CGPointZero
    private var currentTextSize_ = CGFloat(0)
    private var fontSizeAtPinchBegin_ = CGFloat(0)
    private var distanceAtPinchBegin_ = CGFloat(0)
    private var beganTwoFingerPitch_ = false
    private var maximumFontSize_ = CGFloat(0)
    private var fontName_:String = ""
    private var oldText_:String = ""
    private var oldPosition_ = CGPointZero
    private var oldColor_ = UIColor.whiteColor()
    private var oldFontScaleFactor_ = CGFloat(0)
    
    private var completionHandler_:IMGLYSubEditorCompletionBlock!
    public var completionHandler:IMGLYSubEditorCompletionBlock! {
        get {
            return completionHandler_
        }
        set (handler) {
            completionHandler_ = handler
        }
    }
    
    private var fixedFilterStack_:IMGLYFixedFitlerStack?
    public var fixedFilterStack:IMGLYFixedFitlerStack? {
        get {
            return fixedFilterStack_
        }
        set (filterStack) {
            fixedFilterStack_ = filterStack
        }
    }
    
    // MARK:- IMGLYSubEditorViewController
    private var previewImage_:UIImage? = nil
    public var previewImage:UIImage? {
        get {
            return previewImage_
        }
        set (image) {
            previewImage_ = image
        }
    }
    
    public var dialogView:UIView? {
        get {
            return view
        }
        set(newView) {
            view = newView
        }
    }
    
    // MARK:- framework code
    public override func loadView() {
        self.view = IMGLYTextDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        IMGLYInstanceFactory.sharedInstance.fontImporter().importFonts()
        dialogView_ = self.dialogView as? IMGLYTextDialogView
        storeValues()
        dialogView_!.delegate = self
        updatePreviewImage()
        setup()
    }
    
    private func setup() {
        configureTextInput()
        configureTextLabelClipView()
        configureTextLabel()
        configureFontSelector()
        registerForKeyboardNotifications()
        addPanGestureRecognizerToTextInput()
        addPinchGestureRecognizerToTextLabel()
    }
    
    private func configureTextInput() {
        textInput_ = UITextField()
        textInput_!.delegate = self
        textInput_!.backgroundColor = UIColor(white:0.0, alpha:0.5)
        textInput_!.text = ""
        textInput_!.alpha = 0.0
        textInput_!.textColor = textColor_
        textInput_!.clipsToBounds = false
        textInput_!.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        textInput_!.returnKeyType = UIReturnKeyType.Done
        view.addSubview(textInput_!)
    }
    
    private func configureTextLabelClipView() {
        textLabelClipView_ = UIView()
        textLabelClipView_!.frame = CGRectMake(0, 0, 100, 100)
        textLabelClipView_!.clipsToBounds = true
        self.view.addSubview(textLabelClipView_!)
    }
    
    private func configureTextLabel() {
        textLabel_ = UILabel()
        textLabel_!.alpha = 0.0
        textLabel_!.backgroundColor = UIColor(white:0.0, alpha:0.0)
        textLabel_!.textColor = textColor_
        textLabel_!.textAlignment = NSTextAlignment.Center
        textLabel_!.clipsToBounds = true
        textLabel_!.userInteractionEnabled = true
        textLabelClipView_!.addSubview(textLabel_!)
    }
    
    private func configureFontSelector() {
        fontSelector_ = IMGLYFontSelector(frame: CGRectZero)
        fontSelector_!.selectorDelegate = self
        var containerViewHelper = IMGLYInstanceFactory.sharedInstance.containerViewHelper()
        containerViewHelper.addContentViewAndSetupConstraints(hostView: dialogView_!, contentView: fontSelector_!)
    }
    
    // MARK:- notification setup / handling
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    
    private func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification:NSNotification) {
        var info = aNotification.userInfo
        var temp = (aNotification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        keyboardSize_ = temp!.size
        layoutTextInput()
        showTextInput()
    }
    
    // MARK:- gesture setup
    private func addPanGestureRecognizerToTextInput() {
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleTextInputPan:")
        panGestureRecognizer.delegate = self
        textLabel_!.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addPinchGestureRecognizerToTextLabel() {
        var pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    // MARK:- IMGLYTextDialogViewDelegate
    public func doneButtonPressed() {
        textInput_!.resignFirstResponder()
        if self.completionHandler != nil {
            fixedFilterStack!.textFilter!.text = textLabel_!.text!
            fixedFilterStack!.textFilter!.color = textColor_
            fixedFilterStack!.textFilter!.fontName = fontName_
            fixedFilterStack!.textFilter!.position = transformedTextPosition()
            fixedFilterStack!.textFilter!.fontScaleFactor = currentTextSize_ / scaledImageSize().height
            filtredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
            self.completionHandler(IMGLYEditorResult.Done, self.filtredImage_)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        textInput_!.resignFirstResponder()
        if self.completionHandler != nil {
            restoreValues()
            self.completionHandler(IMGLYEditorResult.Cancel, nil)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func selectedColor(color:UIColor) {
        textColor_ = color
        textLabel_!.textColor = color
        textInput_!.textColor = color
    }
    
    // MARK:- Devicerotation   
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public func selectedFontWithName(fontName:String) {
        fontSelector_?.removeFromSuperview()
        fontName_ = fontName
        textInput_!.font = UIFont(name:fontName_, size:kFontSizeInTextInput_)
        textInput_!.becomeFirstResponder()
        fontSelector_!.removeFromSuperview()
    }
    
    // MARK:- layouting
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutTextInput()
        
        // calculate frame of image within imageView
        let imageSize = scaledImageSize()
        let imageFrame = CGRect(x: CGRectGetMidX(dialogView_!.previewImageView.frame) - imageSize.width / 2, y: CGRectGetMidY(dialogView_!.previewImageView.frame) - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
    
        textLabelClipView_!.frame = imageFrame
    }
    
    private func layoutTextInput() {
        textInput_!.frame = CGRectMake(0.0,
            view.frame.size.height - keyboardSize_.height - kTextInputHeight_,
            view.frame.size.width,
            kTextInputHeight_);
    }
    
    // MARK:- gesture handling
    public func handleTextInputPan(recognizer:UIPanGestureRecognizer) {
        var location = recognizer.locationInView(textLabelClipView_)
        if recognizer.state == UIGestureRecognizerState.Began {
            panOffset_ = recognizer.locationInView(textLabel_!)
        }
        var frame = textLabel_!.frame
        frame.origin.x = location.x - panOffset_.x
        frame.origin.y = location.y - panOffset_.y
        textLabel_!.frame = frame
    }
    
    public func handlePinchGesture(recognizer:UIPinchGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            fontSizeAtPinchBegin_ = currentTextSize_
            beganTwoFingerPitch_ = false
        }
        
        if recognizer.numberOfTouches() > 1 {
            var point1 = recognizer.locationOfTouch(0, inView:view)
            var point2 = recognizer.locationOfTouch(1, inView:view)
            if  !beganTwoFingerPitch_ {
                beganTwoFingerPitch_ = true
                distanceAtPinchBegin_ = calculateNewFontSizeBasedOnDistanceBetweenPoint(point1, and:point2)
            }
            var distance = calculateNewFontSizeBasedOnDistanceBetweenPoint(point1, and:point2)
            currentTextSize_ = fontSizeAtPinchBegin_ - (distanceAtPinchBegin_ - distance) / 2.0
            currentTextSize_ = max(kMinimumFontSize_, currentTextSize_)
            currentTextSize_ = min(maximumFontSize_, currentTextSize_)
            textLabel_!.font = UIFont(name:fontName_, size:currentTextSize_)
            updateTextLabelFrameForCurrentFont()
        }
    }
    
    // MARK:- tools
    private func calculateNewFontSizeBasedOnDistanceBetweenPoint(point1:CGPoint, and point2:CGPoint) -> CGFloat {
        var diffX = point1.x - point2.x
        var diffY = point1.y - point2.y
        return sqrt(diffX * diffX + diffY  * diffY)
    }
    
    private func transformedTextPosition() -> CGPoint {
        var scaledSize = scaledImageSize()
        var position = textLabel_!.frame.origin
        position.x = position.x / scaledSize.width
        position.y = position.y / scaledSize.height
        return position
    }
    
    private func scaledImageSize() -> CGSize {
        var widthRatio = dialogView_!.previewImageView.bounds.size.width / dialogView_!.previewImageView.image!.size.width
        var heightRatio = dialogView_!.previewImageView.bounds.size.height / dialogView_!.previewImageView.image!.size.height
        var scale = min(widthRatio, heightRatio)
        var size = CGSizeZero
        size.width = scale * dialogView_!.previewImageView.image!.size.width
        size.height = scale * dialogView_!.previewImageView.image!.size.height
        return size
    }
    
    // MARK:- UITextFieldDelegate
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textInput_!.resignFirstResponder()
        hideTextInput()
        textLabel_!.text = textInput_!.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        setInitialTextLabelSize()
        showTextLabel()
        return true
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK:- text input handling
    private func showTextLabel() {
        UIView.animateWithDuration(0.2, animations:{
            self.textLabel_!.alpha = 1.0
        })
    }
    
    private func showTextInput() {
        UIView.animateWithDuration(0.2, animations:{
            self.textInput_!.alpha = 1.0
        })
    }
    
    private func hideTextInput() {
        UIView.animateWithDuration(0.2, animations:{
            self.textInput_!.alpha = 0.0
        })
    }
    
    private func calculateInitialFontSize() {
        currentTextSize_ = 1.0
        var size = CGSizeZero
        if !textLabel_!.text!.isEmpty {
            do {
                currentTextSize_ += 1.0
                textLabel_!.font = UIFont(name:fontName_, size:currentTextSize_)
                size = textLabel_!.text!.sizeWithAttributes([NSFontAttributeName:textLabel_!.font])
            }
                while (size.width < (view.frame.size.width - kTextLabelInitialMargin_))
        }
    }
    
    private func calculateMaximumFontSize() {
        var size = CGSizeZero
        if !textLabel_!.text!.isEmpty {
            maximumFontSize_ = currentTextSize_
            do {
                maximumFontSize_ += 1.0
                textLabel_!.font = UIFont(name:fontName_, size:maximumFontSize_)
                size = textLabel_!.text!.sizeWithAttributes([NSFontAttributeName:textLabel_!.font])
            }
                while (size.width < (self.view.frame.size.width))
        }
    }
    
    private func setInitialTextLabelSize() {
        calculateInitialFontSize()
        calculateMaximumFontSize()
        
        textLabel_!.font = UIFont(name:fontName_, size:currentTextSize_)
        textLabel_!.sizeToFit()
        textLabel_!.frame.origin.x = kTextLabelInitialMargin_ / 2.0 - textLabelClipView_!.frame.origin.x
        textLabel_!.frame.origin.y = -textLabel_!.frame.size.height / 2.0 + textLabelClipView_!.frame.height / 2.0
    }
    
    private func updateTextLabelFrameForCurrentFont() {
        // resize and keep the text centred
        var frame = textLabel_!.frame
        textLabel_!.sizeToFit()
        
        var diffX = frame.size.width - textLabel_!.frame.size.width
        var diffY = frame.size.height - textLabel_!.frame.size.height
        textLabel_!.frame.origin.x += (diffX / 2.0)
        textLabel_!.frame.origin.y += (diffY / 2.0)
    }
    
    // MARK:- store/restore
    private func storeValues() {
        oldColor_ = fixedFilterStack!.textFilter!.color
        oldPosition_ = fixedFilterStack!.textFilter!.position
        oldText_ = fixedFilterStack!.textFilter!.text
        oldFontScaleFactor_ = fixedFilterStack!.textFilter!.fontScaleFactor
    }
    
    private func restoreValues() {
        fixedFilterStack!.textFilter!.color = oldColor_
        fixedFilterStack!.textFilter!.position = oldPosition_
        fixedFilterStack!.textFilter!.text = oldText_
        fixedFilterStack!.textFilter!.fontScaleFactor = oldFontScaleFactor_
    }
    
    public func updatePreviewImage() {
        if fixedFilterStack != nil {
            fixedFilterStack!.textFilter!.text = ""
            filtredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
            dialogView_!.previewImageView.image = filtredImage_
        }
    }
}

 