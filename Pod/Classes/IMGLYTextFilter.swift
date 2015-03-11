//
//  IMGLYTextFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYTextFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    /// The text that should be rendered.
    public var text = ""
    /// The name of the used font.
    public var fontName = "Helvetica Neue"
    ///  This factor determins the font-size. Its a relative value that is multiplied with the image heigt
    ///  during the process.
    public var fontScaleFactor = CGFloat(1)
    /// The relative position of the text within the image.
    public var position = CGPointZero
    /// The color of the text.
    public var color = UIColor.whiteColor()
    
    override public init() {
        super.init()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    override public var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            if text.isEmpty {
                return inputImage
            }
            
            var textImage = createTextImage()
            var textCIImage = CIImage(CGImage: textImage.CGImage)
            var filter = CIFilter(name: "CISourceOverCompositing")
            filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(textCIImage, forKey: kCIInputImageKey)
            return filter.outputImage
        }
    }
    
    private func createTextImage() -> UIImage {
        var rect = inputImage!.extent()
        var imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height))
        var font = UIFont(name:fontName, size:fontScaleFactor * imageSize.height)
        text.drawAtPoint(CGPointMake(position.x * imageSize.width, position.y * imageSize.height),
            withAttributes: [NSFontAttributeName:font!, NSForegroundColorAttributeName:color])
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}
