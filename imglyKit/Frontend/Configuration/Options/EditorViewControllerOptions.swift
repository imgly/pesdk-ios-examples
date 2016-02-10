//
//  EditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 21/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 Options for configuring a `EditorViewController`.
 */
@objc(IMGLYEditorViewControllerOptions) public class EditorViewControllerOptions: NSObject {

    ///  Defaults to 'Editor'
    public let title: String?

    /// The viewControllers backgroundColor. Defaults to the configurations
    /// global background color.
    public let backgroundColor: UIColor?

    /**
     A configuration closure to configure the given left bar button item.
     Defaults to a 'Cancel' in the apps tintColor or 'Back' when presented within
     a navigation controller.
     */
    public let leftBarButtonConfigurationClosure: BarButtonItemConfigurationClosure?

    /**
     A configuration closure to configure the given done button item.
     Defaults to 'Editor' in the apps tintColor.
     */
    public let rightBarButtonConfigurationClosure: BarButtonItemConfigurationClosure?

    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public let allowsPreviewImageZoom: Bool

    /**
     Returns a newly allocated instance of a `EditorViewControllerOptions` using the default builder.

     - returns: An instance of a `EditorViewControllerOptions`.
     */
    public convenience override init() {
        self.init(editorBuilder: EditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `EditorViewControllerOptions` using the given builder.

     - parameter builder: A `EditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `EditorViewControllerOptions`.
     */
    public init(editorBuilder: EditorViewControllerOptionsBuilder) {
        title = editorBuilder.title
        backgroundColor = editorBuilder.backgroundColor
        leftBarButtonConfigurationClosure = editorBuilder.leftBarButtonConfigurationClosure
        rightBarButtonConfigurationClosure = editorBuilder.rightBarButtonConfigurationClosure
        allowsPreviewImageZoom = editorBuilder.allowsPreviewImageZoom
        super.init()
    }
}

/**
 The default `EditorViewControllerOptionsBuilder` for `EditorViewControllerOptions`.
 */
@objc(IMGLYEditorViewControllerOptionsBuilder) public class EditorViewControllerOptionsBuilder: NSObject {
    ///  Defaults to 'Editor'
    public lazy var title: String? = "Editor"

    /// The viewControllers backgroundColor. Defaults to the configurations
    /// global background color.
    public var backgroundColor: UIColor?

    /**
     A configuration closure to configure the given left bar button item.
     Defaults to a 'Cancel' in the apps tintColor or 'Back' when presented within
     a navigation controller.
     */
    public var leftBarButtonConfigurationClosure: BarButtonItemConfigurationClosure? = nil

    /**
     A configuration closure to configure the given done button item.
     Defaults to 'Editor' in the apps tintColor.
     */
    public var rightBarButtonConfigurationClosure: BarButtonItemConfigurationClosure? = nil

    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public var allowsPreviewImageZoom = true
}
