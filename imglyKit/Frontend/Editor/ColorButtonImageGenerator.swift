//
//  ColorButtonImageGenerator.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYColorButtonImageGenerator) public class ColorButtonImageGenerator: NSObject {
    private var image: UIImage? = nil
    private var backgroundImage: UIImage? = nil

    /**
     Returns a new instance of a `ColorButtonImageGenerator`.

     - parameter imageName:           An image defining the shape of the selected color indicator.
     - parameter backgroundImageName: An image definint the background.

     - returns: A new instance.
     */
    public init(imageName: String, backgroundImageName: String) {
        super.init()
        let bundle = NSBundle(forClass: ColorButtonImageGenerator.self)
        image = UIImage(named: imageName, inBundle: bundle, compatibleWithTraitCollection: nil)
        image = image?.imageWithRenderingMode(.AlwaysTemplate)
        backgroundImage = UIImage(named: backgroundImageName, inBundle: bundle, compatibleWithTraitCollection: nil)
    }

    /**
     Returns a new image made of the combined back- and color image.

     - parameter color: The color that the color indicator image is set to.

     - returns: A new `UIImage`.
     */
    public func imageWithColor(color: UIColor) -> UIImage? {
        guard let backgroundImage = backgroundImage, let image = image else {
            return nil
        }

        let size = backgroundImage.size`
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
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