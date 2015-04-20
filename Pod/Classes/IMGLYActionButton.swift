//
//  IMGLYActionButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias IMGLYActionButtonHandler = () -> (Void)
public typealias IMGLYShowSelectionBlock = () -> (Bool)

@objc public class IMGLYActionButton {
    let title: String?
    let image: UIImage?
    let selectedImage: UIImage?
    let handler: IMGLYActionButtonHandler
    let showSelection: IMGLYShowSelectionBlock?
        
    init(title: String?, image: UIImage?, selectedImage: UIImage? = nil, handler: IMGLYActionButtonHandler, showSelection: IMGLYShowSelectionBlock? = nil) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.handler = handler
        self.showSelection = showSelection
    }
}
