//
//  Border.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYBorder) public class Border: NSObject {
    public let image: UIImage
    public let thumbnail: UIImage?
    public let label: String?
    public let ratio: Float
    public let url: String?

    public init(image: UIImage, thumbnail: UIImage?, label: String?, ratio: Float, url: String?) {
        self.image = image
        self.thumbnail = thumbnail
        self.label = label
        self.ratio = ratio
        self.url = url
        super.init()
    }
}
