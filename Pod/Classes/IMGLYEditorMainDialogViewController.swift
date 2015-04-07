//
//  IMGLYEditorMainDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 06/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum IMGLYEditorResult: Int {
    case Done,
    Cancel
}

public typealias IMGLYSubEditorCompletionBlock = (IMGLYEditorResult,UIImage?)->Void
public typealias IMGLYEditorCompletionBlock = (IMGLYEditorResult,UIImage?)->Void

@objc public protocol IMGLYSubEditorViewControllerProtocol {
    var previewImage:UIImage? {set get}
    var completionHandler:IMGLYSubEditorCompletionBlock? {get set}
    var fixedFilterStack:IMGLYFixedFilterStack? {get set}
    var dialogView:UIView? {get set}
    func viewDidLoad()
}

@objc public protocol IMGLYEditorMainDialogViewControllerProtocol {
    var hiResImage:UIImage? {get set}
    var initialFilterType:IMGLYFilterType {get set}
    var completionBlock:IMGLYEditorCompletionBlock? {get set}
}

public class IMGLYEditorMainDialogViewController: UIViewController, UIViewControllerTransitioningDelegate,
        IMGLYEditorMainDialogViewDelegate, IMGLYEditorMainDialogViewControllerProtocol {
    public let maximalLoResSideLength:CGFloat! = 800

    public var initialFilterType = IMGLYFilterType.None
    public var completionBlock:IMGLYEditorCompletionBlock? = nil

    private var hiResImage_:UIImage?
    public var hiResImage:UIImage? {
        get {
            return hiResImage_
        }
        set (image) {
            hiResImage_ = image
            generateLoResVersion()
        }
    }
    
    private var loResImage_:UIImage? = nil
    private var loResImageBackup_:UIImage? = nil
    private var fixedFilterStack_:IMGLYFixedFilterStack? = nil

    public override func loadView() {
        self.view = IMGLYEditorMainDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        var editorView = self.view as? IMGLYEditorMainDialogView
        if editorView == nil {
            fatalError("Editor view not set !")
        }
        editorView?.delegate = self
        fixedFilterStack_ = IMGLYFixedFilterStack()
        fixedFilterStack_!.effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(initialFilterType) as? IMGLYResponseFilter
        updatePreviewImage()
    }
    
    // MARK:-IMGLYEditorMainDialogViewDelegate
    public func menuButtonPressed(buttonType:IMGLYMainMenuButtonType) {
        var viewController = IMGLYInstanceFactory.sharedInstance.viewControllerForButtonType(buttonType)
        if (buttonType == IMGLYMainMenuButtonType.Magic) {
            fixedFilterStack_!.enhancementFilter!.enabled = !fixedFilterStack_!.enhancementFilter!.enabled
            updatePreviewImage()
        }
        else {
            if viewController != nil {
                viewController!.fixedFilterStack = fixedFilterStack_!
                viewController!.previewImage = loResImageBackup_
                viewController!.completionHandler = subEditorCompletionBlock
                
                if let viewController = viewController as? UIViewController {
                    viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                }
                
                self.presentViewController(viewController as! UIViewController, animated: true) { () -> Void in }
            }
        }
    }
    
    public func doneButtonPressed() {
        hiResImage! = hiResImage!.imageRotatedToMatchOrientation
        var filteredHiResImage = IMGLYPhotoProcessor.processWithUIImage(hiResImage!, filters:fixedFilterStack_!.activeFilters)
        self.dismissViewControllerAnimated(true, completion: {
            self.completionBlock?(IMGLYEditorResult.Done, filteredHiResImage)
        })
    }
    
    public func backButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: {
            if self.completionBlock != nil {
                self.completionBlock!(IMGLYEditorResult.Cancel, nil)
            }
        })
    }

    public func subEditorCompletionBlock(result:IMGLYEditorResult, image:UIImage?) {
        if result == IMGLYEditorResult.Done {
            self.loResImage_ = image
            var editorView = self.view as? IMGLYEditorMainDialogView
            editorView?.imagePreview.image = self.loResImage_
        }
    }
    
    public func generateLoResVersion() {
        if hiResImage?.size.width > maximalLoResSideLength || hiResImage?.size.height > maximalLoResSideLength  {
            var scale:Double = 1.0
            if(hiResImage?.size.width > hiResImage?.size.height) {
                scale = Double(maximalLoResSideLength) / Double(hiResImage!.size.width)
            }
            else {
                scale = Double(maximalLoResSideLength) / Double(hiResImage!.size.height)
            }
            
            var newWidth:CGFloat = CGFloat(roundf(Float(hiResImage!.size.width) * Float(scale)))
            var newHeight:CGFloat = CGFloat(roundf(Float(hiResImage!.size.height) * Float(scale)))
            loResImage_ = hiResImage?.imageResizedToSize(CGSize(width: newWidth, height: newHeight), withInterpolationQuality: kCGInterpolationDefault)
            loResImageBackup_ = UIImage(CGImage: loResImage_?.CGImage)
        } else {
            loResImage_ = UIImage(CGImage: hiResImage!.CGImage)
            loResImageBackup_ = UIImage(CGImage: hiResImage!.CGImage)
        }
    }
    
    private func updatePreviewImage() {
        var editorView = self.view as? IMGLYEditorMainDialogView
        if editorView == nil {
            fatalError("Editor view not set !")
        }
        editorView?.imagePreview.image = IMGLYPhotoProcessor.processWithUIImage(loResImage_!, filters:fixedFilterStack_!.activeFilters)
    }
    
    // MARK:- Device rotation    
    public override func shouldAutorotate() -> Bool {
        return false
    }
}
