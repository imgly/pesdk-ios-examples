//
//  IMGLYFilterDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYFilterDialogViewController: UIViewController, IMGLYSubEditorViewControllerProtocol,
    IMGFilterSelectorViewDelegate, IMGLYFilterDialogViewDelegate {
    
    private var filterDialogView_:IMGLYFilterDialogView?
    private var previewImage_:UIImage? = nil
    private var filteredImage_:UIImage? = nil
    private var selectedFilterType_:IMGLYFilterType = IMGLYFilterType.None
    private var oldSelectedFilterType_:IMGLYFilterType = IMGLYFilterType.None
    
    // MARK:- IMGLYSubEditorViewController
    private var completionHandler_:IMGLYSubEditorCompletionBlock!
    public var completionHandler:IMGLYSubEditorCompletionBlock! {
        get {
            return completionHandler_
        }
        set (handler) {
            completionHandler_ = handler
        }
    }
    
    private var fixedFilterStack_:IMGLYFixedFilterStack?
    public var fixedFilterStack:IMGLYFixedFilterStack? {
        get {
            return fixedFilterStack_
        }
        set (filterStack) {
            fixedFilterStack_ = filterStack
        }
    }
    
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
    
    public override func loadView() {
        self.view = IMGLYFilterDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    // MARK:- Framework code
    public override func viewDidLoad() {
        super.viewDidLoad()
        filterDialogView_ = self.view as? IMGLYFilterDialogView
        if filterDialogView_ != nil {
            filterDialogView_!.filterSelectorView.delegate = self
            filterDialogView_!.delegate = self
            filteredImage_ = previewImage
            selectedFilterType_ = fixedFilterStack!.effectFilter!.filterType
            updatePreviewImage()
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        dispatch_async (dispatch_get_main_queue(), {
            self.filterDialogView_!.filterSelectorView.commonInit()
        })
    }
    
    // MARK:- IMGFilterSelectorViewDelegate
    public func didSelectFilter(filter:IMGLYFilterType) {
        selectedFilterType_ = filter
        updatePreviewImage()
    }
    
    private func updatePreviewImage() {
        var actualFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(selectedFilterType_)
        if fixedFilterStack != nil {
            fixedFilterStack!.setEffectFilter(actualFilter!)
            filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
        }
        filterDialogView_!.previewImageView.image = filteredImage_
    }
    
    // MARK:- Completion-block handling
    public func doneButtonPressed() {
        if self.completionHandler != nil {
            self.completionHandler(IMGLYEditorResult.Done, self.filteredImage_)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        if self.completionHandler != nil {
            var actualFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(oldSelectedFilterType_)
            if fixedFilterStack != nil {
                fixedFilterStack!.setEffectFilter(actualFilter!)
            }
            self.completionHandler(IMGLYEditorResult.Cancel, nil)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK:- Devicerotation    
    public override func shouldAutorotate() -> Bool {
        return false
    }
}
