//
//  BorderEditorViewControllerOptions.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit


/// This closure is called when the user adds a border.
public typealias AddedBorderClosure = (String) -> ()

/**
 Options for configuring a `BordersEditorViewController`.
 */
@objc(IMGLYBorderEditorViewControllerOptions) public class BorderEditorViewControllerOptions: EditorViewControllerOptions {

    /// An object conforming to the `BordersDataSourceProtocol`
    /// Per default an `BordersDataSource` offering all filters
    /// is set.
    public let bordersDataSource: BordersDataSourceProtocol

    /// This closure is called when the user adds a border.
    public let addedBorderClosure: AddedBorderClosure?

    /// The tolerance that is used to pick the correct border image based on the aspect ratio.
    public var tolerance: Float

    /**
     Returns a newly allocated instance of a `BorderEditorViewControllerOptions` using the default builder.

     - returns: An instance of a `MainEditorViewControllerOptions`.
     */
    public convenience init() {
        self.init(builder: BorderEditorViewControllerOptionsBuilder())
    }

    /**
     Returns a newly allocated instance of a `BorderEditorViewControllerOptions` using the given builder.

     - parameter builder: A `BorderEditorViewControllerOptionsBuilder` instance.

     - returns: An instance of a `BorderEditorViewControllerOptions`.
     */
    public init(builder: BorderEditorViewControllerOptionsBuilder) {
        bordersDataSource = builder.bordersDataSource
        addedBorderClosure = builder.addedBorderClosure
        tolerance = builder.tolerance
        super.init(editorBuilder: builder)
    }
}

// swiftlint:disable type_name
/**
The default `BorderEditorViewControllerOptionsBuilder` for `BorderEditorViewControllerOptions`.
*/
@objc(IMGLYBorderEditorViewControllerOptionsBuilder) public class BorderEditorViewControllerOptionsBuilder: EditorViewControllerOptionsBuilder {
    // swiftlint:enable type_name

    /// An object conforming to the `BordersDataSourceProtocol`
    /// Per default an `BordersDataSource` offering all filters
    /// is set.
    public var bordersDataSource: BordersDataSourceProtocol = BordersDataSource()

    /// This closure is called when the user adds a border.
    public var addedBorderClosure: AddedBorderClosure? = nil

    /// The tolerance that is used to pick the correct border image based on the aspect ratio.
    public var tolerance: Float = 0.1

    /**
     :nodoc:
     */
    public override init() {
        super.init()

        /// Override inherited properties with default values
        self.title = Localize("Borders")
    }
}
