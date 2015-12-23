//
//  IMGLYActionButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/// An available editor action for the main editor
@objc public class IMGLYMainEditorAction: NSObject {
    let title: String?
    let image: UIImage?
    let selectedImage: UIImage?
    let editorType: IMGLYMainEditorActionType

    /**
     - parameter title:         The title shown below the icon
     - parameter image:         The editors icon when shown in the main editors bottom drawer
     - parameter selectedImage: The editors selected icon
     - parameter editorType:    The editors type

     - returns: An IMGLYMainEditorActionItem with the given values
     */
    init(title: String?, image: UIImage?, selectedImage: UIImage? = nil, editorType: IMGLYMainEditorActionType) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.editorType = editorType
    }
}
