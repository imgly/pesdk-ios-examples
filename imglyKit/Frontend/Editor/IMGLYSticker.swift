//
//  IMGLYSticker.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public class IMGLYSticker: NSObject {
    public let image: UIImage
    public let thumbnail: UIImage?
    
    public init(image: UIImage, thumbnail: UIImage?) {
        self.image = image
        self.thumbnail = thumbnail
        super.init()
    }
}
