//
//  CropRatio.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 25/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 *  Instances of this class can be used together with the `CropEditorViewController` to specify the
 *  crop ratios that should be supported.
 */
@objc(IMGLYCropRatio) public class CropRatio: NSObject {

    /// The ratio of the crop as `CGFloat`.
    public let ratio: CGFloat?

    /// A name to be shown in the UI.
    public let title: String

    // An icon to be shown in the UI.
    public let icon: UIImage

    /**
     Initializes and returns a newly allocated crop ratio object with the specified ratio, title and icon.

     - parameter ratio: The aspect ratio to enforce. If this is `nil`, the user can perform a free form crop.
     - parameter title: The title of this aspect ratio, e.g. '1:1'
     - parameter icon:  The icon to use for this aspect ratio. The image should be 36x36 pixels.

     - returns: An initialized crop ratio object.
     */
    public init(ratio: CGFloat?, title: String, accessibilityLabel: String?, icon: UIImage) {
        self.ratio = ratio
        self.title = title
        self.icon = icon
        super.init()

        self.accessibilityLabel = accessibilityLabel
    }
}
