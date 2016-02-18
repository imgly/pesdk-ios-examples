//
//  Border.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYBorder) public class Border: NSObject {
    public let thumbnail: UIImage?
    public let label: String?

    private var ratioToImageMap = [Float : UIImage]()

    public init(thumbnail: UIImage?, label: String?) {
        self.thumbnail = thumbnail
        self.label = label
        super.init()
    }

    public func imageForRatio(ratio: Float) -> UIImage? {
        return ratioToImageMap[ratio]
    }

    public func addImage(image: UIImage, ratio: Float) {
        ratioToImageMap[ratio] = image
    }
}
