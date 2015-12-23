//
//  IMGLYSubEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias IMGLYSubEditorCompletionBlock = (UIImage?, IMGLYFixedFilterStack) -> (Void)
public typealias IMGLYPreviewImageGenerationCompletionBlock = () -> (Void)

public class IMGLYSubEditorViewController: IMGLYEditorViewController {
    
    // MARK: - Properties
    
    public var fixedFilterStack: IMGLYFixedFilterStack = IMGLYFixedFilterStack()
    public var completionHandler: IMGLYSubEditorCompletionBlock?
    
    // MARK: - Initializers
    
    public init(fixedFilterStack: IMGLYFixedFilterStack, configuration: IMGLYConfiguration) {
        self.fixedFilterStack = fixedFilterStack.copy() as! IMGLYFixedFilterStack
        super.init(configuration: configuration)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    // MARK: - EditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        completionHandler?(previewImageView.image, fixedFilterStack)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helpers
    
    public func updatePreviewImageWithCompletion(completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(PhotoProcessorQueue) {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image = processedImage
                    self.updating = false
                    completionHandler?()
                }
            }
        }
    }
    
    internal func updatePreviewImage() {
        updatePreviewImageWithCompletion(nil)
    }
}