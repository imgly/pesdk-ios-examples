 //
 //  IMGLYFocusDialogViewController.swift
 //  imglyKit
 //
 //  Created by Carsten Przyluczky on 19/02/15.
 //  Copyright (c) 2015 9elements GmbH. All rights reserved.
 //
 
 import Foundation
 
 public class IMGLYFocusDialogViewController: UIViewController, IMGLYSubEditorViewControllerProtocol,
 IMGLYFocusDialogViewDelegate, IMGLYGradientViewDelegate {
    
    public var completionHandler:IMGLYSubEditorCompletionBlock!
    public var fixedFilterStack:IMGLYFixedFitlerStack?
    
    private var dialogView_:IMGLYFocusDialogView?
    private var filtredImage_:UIImage? = nil
    private var nonBlurryImage_:UIImage? = nil
    private var circleGradientView_:IMGLYCircleGradientView? = nil
    private var boxGradientView_:IMGLYBoxGradientView? = nil
    private let gradientViewYOffset:CGFloat = 28 // havent tracked down why this is 28
    private var tiltShiftType = IMGLYTiltshiftType.Box
    private var oldTiltShiftType = IMGLYTiltshiftType.Off
    private var oldControlPoint1 = CGPointZero
    private var oldControlPoint2 = CGPointZero
    
    public var dialogView:UIView? {
        get {
            return view
        }
        set(newView) {
            view = newView
        }
    }
    
    // MARK:- IMGLYSubEditorViewController
    public var previewImage:UIImage?
    
    // MARK:- Framework code
    override public func viewDidLoad() {
        super.viewDidLoad()
        dialogView_ = self.view as? IMGLYFocusDialogView
        if dialogView_ != nil {
            dialogView_!.delegate = self
            filtredImage_ = previewImage
            setupCircleGradientView()
            setupBoxGradientView()
            storeOldValues()
        }
    }
    
    private func setupCircleGradientView() {
        circleGradientView_ = IMGLYInstanceFactory.sharedInstance.circleGradientView()
        circleGradientView_!.gradientViewDelegate = self
        circleGradientView_!.hidden = true
        circleGradientView_!.alpha = 0
        dialogView_!.addSubview(circleGradientView_!)
    }
    
    private func setupBoxGradientView() {
        boxGradientView_ = IMGLYInstanceFactory.sharedInstance.boxGradientView()
        boxGradientView_!.gradientViewDelegate = self
        boxGradientView_!.hidden = true
        boxGradientView_!.alpha = 0
        dialogView_!.addSubview(boxGradientView_!)
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        layoutCircleGradientView()
        layoutBoxGradientView()
        createNonBlurryImage()
        updatePreviewImage()
        showBoxGradientView()
    }
    
    private func updatePreviewImage() {
        if fixedFilterStack != nil {
            if tiltShiftType == IMGLYTiltshiftType.Circle {
                fixedFilterStack!.tiltShiftFilter!.controlPoint1 = circleGradientView_!.normalizedControlPoint1
                fixedFilterStack!.tiltShiftFilter!.controlPoint2 = circleGradientView_!.normalizedControlPoint2
            } else if tiltShiftType == IMGLYTiltshiftType.Box {
                fixedFilterStack!.tiltShiftFilter!.controlPoint1 = boxGradientView_!.normalizedControlPoint1
                fixedFilterStack!.tiltShiftFilter!.controlPoint2 = boxGradientView_!.normalizedControlPoint2
            }
            fixedFilterStack!.tiltShiftFilter!.tiltShiftType = tiltShiftType
            
            filtredImage_ = IMGLYInstanceFactory.sharedInstance.photoProcessor().process(image:previewImage!,
                filters: fixedFilterStack!.activeFilters)
        }
        dialogView_!.previewImageView.image = filtredImage_
    }
    
    private func createNonBlurryImage() {
        fixedFilterStack!.tiltShiftFilter!.tiltShiftType = IMGLYTiltshiftType.Off
        nonBlurryImage_ = IMGLYInstanceFactory.sharedInstance.photoProcessor().process(image:previewImage!, filters: fixedFilterStack!.activeFilters)
        fixedFilterStack!.tiltShiftFilter!.tiltShiftType = oldTiltShiftType
    }
    
    private func layoutCircleGradientView() {
        var size = scaledImageSize()
        var xOffset = (dialogView!.frame.size.width - size.width) / 2.0
        var yOffset = (dialogView!.frame.size.height - size.height ) / 2.0
        circleGradientView_!.frame = CGRectMake(xOffset,
            yOffset - gradientViewYOffset,
            size.width,
            size.height)
        circleGradientView_!.centerGUIElements()
    }
    
    private func layoutBoxGradientView() {
        var size = scaledImageSize()
        var xOffset = (dialogView!.frame.size.width - size.width) / 2.0
        var yOffset = (dialogView!.frame.size.height - size.height ) / 2.0
        boxGradientView_!.frame = CGRectMake(xOffset,
            yOffset - gradientViewYOffset,
            size.width,
            size.height)
        boxGradientView_!.centerGUIElements()
    }
    
    private func scaledImageSize() -> CGSize {
        var widthRatio = dialogView_!.previewImageView.bounds.size.width / previewImage!.size.width
        var heightRatio = dialogView_!.previewImageView.bounds.size.height / previewImage!.size.height
        var scale = min(widthRatio, heightRatio)
        var size = CGSizeZero
        size.width = scale * previewImage!.size.width
        size.height = scale * previewImage!.size.height
        return size
    }
    
    // MARK:- IMGLYFocusDialogViewDelegate
    public func doneButtonPressed() {
        if self.completionHandler != nil {
            self.completionHandler(IMGLYEditorResult.Done, self.filtredImage_)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        restoreOldValues()
        if self.completionHandler != nil {
            self.completionHandler(IMGLYEditorResult.Cancel, nil)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func linearButtonPressed() {
        tiltShiftType = IMGLYTiltshiftType.Box
        hideCircleGradientView()
        showBoxGradientView()
        updatePreviewImage()
    }
    
    public func radialButtonPressed() {
        tiltShiftType = IMGLYTiltshiftType.Circle
        hideBoxGradientView()
        showCircleGradientView()
        updatePreviewImage()
    }
    
    public func offButtonPressed() {
        tiltShiftType = IMGLYTiltshiftType.Off
        hideBoxGradientView()
        hideCircleGradientView()
        updatePreviewImage()
    }
    
    // MARK:- Visibility
    private func showCircleGradientView() {
        circleGradientView_!.hidden = false
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.circleGradientView_!.alpha = 1.0
        })
    }
    
    private func hideCircleGradientView() {
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.circleGradientView_!.alpha = 0.0
            },
            completion: { finished in
                if(finished) {
                    self.circleGradientView_!.hidden = true
                }
            }
        )
    }
    
    private func showBoxGradientView() {
        boxGradientView_!.hidden = false
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.boxGradientView_!.alpha = 1.0
        })
    }
    
    private func hideBoxGradientView() {
        UIView.animateWithDuration(NSTimeInterval(0.15), animations: {
            self.boxGradientView_!.alpha = 0.0
            },
            completion: { finished in
                if(finished) {
                    self.boxGradientView_!.hidden = true
                }
            }
        )
    }
    
    // MARK:- IMGLYGradientViewDelegate
    public func userInteractionStarted() {
        dialogView_!.previewImageView.image = nonBlurryImage_
    }
    
    public func userInteractionEnded() {
        updatePreviewImage()
    }
    
    public func controlPointChanged() {
        
    }
    
    // MARK:- Value store/restore
    private func storeOldValues() {
        oldTiltShiftType = fixedFilterStack!.tiltShiftFilter!.tiltShiftType
        oldControlPoint1 = fixedFilterStack!.tiltShiftFilter!.controlPoint1
        oldControlPoint2 = fixedFilterStack!.tiltShiftFilter!.controlPoint2
    }
    
    private func restoreOldValues() {
        fixedFilterStack!.tiltShiftFilter!.tiltShiftType = oldTiltShiftType
        fixedFilterStack!.tiltShiftFilter!.controlPoint1 = oldControlPoint1
        fixedFilterStack!.tiltShiftFilter!.controlPoint2 = oldControlPoint2
    }
 }
