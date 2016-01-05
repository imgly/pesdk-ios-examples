//
//  ActionButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

/// An available editor action for the main editor
@objc(IMGLYMainEditorAction) public class MainEditorAction: NSObject {
    public let title: String?
    public let image: UIImage?
    public let selectedImage: UIImage?
    public let editorType: MainEditorActionType

    /**
     - parameter title:         The title shown below the icon
     - parameter image:         The editors icon when shown in the main editors bottom drawer
     - parameter selectedImage: The editors selected icon
     - parameter editorType:    The editors type

     - returns: An MainEditorActionItem with the given values
     */
    public init(title: String?, image: UIImage?, selectedImage: UIImage? = nil, editorType: MainEditorActionType) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.editorType = editorType
    }
}
