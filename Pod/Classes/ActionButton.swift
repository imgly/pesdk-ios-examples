//
//  ActionButton.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias ActionButtonHandler = () -> (Void)
public typealias ShowSelectionBlock = () -> (Bool)

@objc(IMGLYActionButton) public class ActionButton {
    let title: String?
    let image: UIImage?
    let selectedImage: UIImage?
    let handler: ActionButtonHandler
    let showSelection: ShowSelectionBlock?
        
    init(title: String?, image: UIImage?, selectedImage: UIImage? = nil, handler: ActionButtonHandler, showSelection: ShowSelectionBlock? = nil) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.handler = handler
        self.showSelection = showSelection
    }
}
