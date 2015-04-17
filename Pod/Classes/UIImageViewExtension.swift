//
//  UIImageViewExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public extension UIImageView {
    // calculate frame of image within imageView
    var imageFrame: CGRect {
        let imageSize: CGSize
        
        if let image = image {
            var widthRatio = bounds.size.width / image.size.width
            var heightRatio = bounds.size.height / image.size.height
            var scale = min(widthRatio, heightRatio)
            var size = CGSizeZero
            size.width = scale * image.size.width
            size.height = scale * image.size.height
            imageSize = size
        } else {
            imageSize = bounds.size
        }
        
        return CGRect(x: CGRectGetMidX(bounds) - imageSize.width / 2, y: CGRectGetMidY(bounds) - imageSize.height / 2, width: imageSize.width, height: imageSize.height)
    }
}
