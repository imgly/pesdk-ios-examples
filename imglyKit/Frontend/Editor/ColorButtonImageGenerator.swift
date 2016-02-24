//
//  ColorButtonImageGenerator.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYColorButtonImageGenerator) public class ColorButtonImageGenerator: NSObject {
//    private var imageName = "imgly_icon_option_selected_color"
//    public var backgroundImageName = "imgly_icon_option_selected_color_bg"

    private var image: UIImage? = nil
    private var backgroundImage: UIImage? = nil

    public init(imageName: String, backgroundImageName: String) {
        super.init()
        let bundle = NSBundle(forClass: ColorButtonImageGenerator.self)
        image = UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        backgroundImage = UIImage(named: backgroundImageName, inBundle: bundle, compatibleWithTraitCollection: nil)
    }

    public func imageWithColor(color: UIColor) -> UIImage? {
        guard let backgroundImage = backgroundImage, let image = image else {
            return nil
        }

        let size = backgroundImage.size
        UIGraphicsBeginImageContext(size)

        let pointImg1 = CGPoint.zero

        backgroundImage.drawAtPoint(pointImg1)

        let pointImg2 = CGPoint.zero
        color.setFill()
        image.drawAtPoint(pointImg2)

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
