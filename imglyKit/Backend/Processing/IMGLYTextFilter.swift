//
//  IMGLYTextFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
import CoreImage
import UIKit
#elseif os(OSX)
import QuartzCore
import AppKit
#endif

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
    
    public var transform = CGAffineTransformIdentity

    public var cropRect = CGRectMake(0, 0, 1, 1)
    
    /// The color of the text.
    #if os(iOS)
    public var color = UIColor.whiteColor()
    #elseif os(OSX)
    public var color = NSColor.whiteColor()
    #endif
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        
        if text.isEmpty {
            return inputImage
        }
        
        let textImage = createTextImage()
        
        if let cgImage = textImage.CGImage, filter = CIFilter(name: "CISourceOverCompositing") {
            let textCIImage = CIImage(CGImage: cgImage)
            filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(textCIImage, forKey: kCIInputImageKey)
            return filter.outputImage
        } else {
            return inputImage
        }
    }
    
    #if os(iOS)
    
    private func createTextImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        
        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        print(originalSize)
        print(cropRect)
        
        var position = CGPoint(x: frame.origin.x * originalSize.width, y: frame.origin.y * originalSize.height)
        position.x -= (cropRect.origin.x * originalSize.width)
        position.y -= (cropRect.origin.y * originalSize.height)
        
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        customParagraphStyle.lineBreakMode = NSLineBreakMode.ByClipping
        let font = UIFont(name: fontName, size: fontScaleFactor * originalSize.height)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextConcatCTM(context, self.transform)
        text.drawAtPoint(position, withAttributes:  [NSFontAttributeName: font!, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: customParagraphStyle.copy() as! NSParagraphStyle])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    #elseif os(OSX)
    
    private func createTextImage() -> NSImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
    
        let image = NSImage(size: imageSize)
        image.lockFocus()
        NSColor(white: 1, alpha: 0).setFill()
        NSRectFill(CGRect(origin: CGPoint(), size: imageSize))
        let font = NSFont(name: fontName, size: fontScaleFactor * imageSize.height)
    
        text.drawInRect(CGRect(x: frame.origin.x * imageSize.width, y: frame.origin.y * imageSize.height, width: frame.size.width * imageSize.width, height: frame.size.height * imageSize.width), withAttributes: [NSFontAttributeName: font!, NSForegroundColorAttributeName: color])
    
        image.unlockFocus()
        
        return image
    }

    #endif
}

extension IMGLYTextFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYTextFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.text = (text as NSString).copyWithZone(zone) as! String
        copy.fontName = (fontName as NSString).copyWithZone(zone) as! String
        copy.fontScaleFactor = fontScaleFactor
        copy.cropRect = cropRect
        copy.frame = frame
        #if os(iOS)
        copy.color = color.copyWithZone(zone) as! UIColor
        #elseif os(OSX)
        copy.color = color.copyWithZone(zone) as! NSColor
        #endif
        
        return copy
    }
}
