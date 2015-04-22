//
//  IMGLYTextFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import CoreImage
import UIKit

public class IMGLYTextFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    /// The text that should be rendered.
    public var text = ""
    /// The name of the used font.
    public var fontName = "Helvetica Neue"
    ///  This factor determins the font-size. Its a relative value that is multiplied with the image height
    ///  during the process.
    public var fontScaleFactor = CGFloat(1)
    /// The relative frame of the text within the image.
    public var frame = CGRect()
    /// The color of the text.
    public var color = UIColor.whiteColor()
    
    override init() {
        super.init()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
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
    
    private func createTextImage() -> UIImage {
        var rect = inputImage!.extent()
        var imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height))
        
        var font = UIFont(name:fontName, size:fontScaleFactor * imageSize.height)
        text.drawInRect(CGRect(x: frame.origin.x * imageSize.width, y: frame.origin.y * imageSize.height, width: frame.size.width * imageSize.width, height: frame.size.height * imageSize.width),
            withAttributes: [NSFontAttributeName:font!, NSForegroundColorAttributeName:color])
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
}

extension IMGLYTextFilter: NSCopying {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYTextFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.text = (text as NSString).copyWithZone(zone) as! String
        copy.fontName = (fontName as NSString).copyWithZone(zone) as! String
        copy.fontScaleFactor = fontScaleFactor
        copy.frame = frame
        copy.color = color.copyWithZone(zone) as! UIColor
        return copy
    }
}
