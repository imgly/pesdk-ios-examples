//
//  BorderInfoRecord.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

/**
 *  Represents a single image entry nested within a border-JSON file.
 */
@objc(IMGLYImageInfoRecord) public class ImageInfoRecord: NSObject {
    /// The image ratio that image has, is out for.
    public var ratio: Float = 1.0

    /// The URL of the image.
    public var url = ""
}

/**
 *  Represents a single border information retrieved via JSON.
 */
@objc(IMGLYBorderInfoRecord) public class BorderInfoRecord: NSObject {
    /// The name of the image.
    public var name = ""

    /// The label of the border. This is used for accessibility.
    public var label = ""

    /// The URL for the thumbnail.
    public var thumbnailURL = ""

    /// An array of `ImageInfoRecord` representing the associated  images.
    public var imageInfos = [ImageInfoRecord]()
}
