//
//  SubEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias SubEditorCompletionBlock = (UIImage?, FixedFilterStack) -> (Void)
public typealias PreviewImageGenerationCompletionBlock = () -> (Void)

@objc(IMGLYSubEditorViewController) public class SubEditorViewController: EditorViewController {
    
    // MARK: - Properties
    
    public let fixedFilterStack: FixedFilterStack
    public var completionHandler: SubEditorCompletionBlock?
    
    // MARK: - Initializers
    
    public init(fixedFilterStack: FixedFilterStack) {
        self.fixedFilterStack = fixedFilterStack.copy() as! FixedFilterStack
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - EditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        completionHandler?(previewImageView.image, fixedFilterStack)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helpers
    
    internal func updatePreviewImageWithCompletion(completionHandler: PreviewImageGenerationCompletionBlock?) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
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