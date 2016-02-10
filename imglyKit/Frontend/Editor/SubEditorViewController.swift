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

    @NSCopying public var fixedFilterStack: FixedFilterStack = FixedFilterStack()
    public var completionHandler: SubEditorCompletionBlock?

    // MARK: - Initializers

    public init(fixedFilterStack: FixedFilterStack, configuration: Configuration) {
        // swiftlint:disable force_cast
        self.fixedFilterStack = fixedFilterStack.copy() as! FixedFilterStack
        // swiftlint:enable force_cast

        super.init(configuration: configuration)
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
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

    public func updatePreviewImageWithCompletion(completionHandler: PreviewImageGenerationCompletionBlock?) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(kPhotoProcessorQueue) {
                let processedImage = PhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)

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
