//
//  Sticker.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYSticker) public class Sticker: NSObject {
    public let image: UIImage
    public let thumbnail: UIImage?
    public let label: String?

    public init(image: UIImage, thumbnail: UIImage?, label: String?) {
        self.image = image
        self.thumbnail = thumbnail
        self.label = label
        super.init()
    }
}
