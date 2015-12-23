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
    
    /// The sticker that should be rendered.
    #if os(iOS)
    public var sticker: UIImage? {
        return createTextImage()
    }
    #elseif os(OSX)
    public var sticker: NSImage?
    #endif
    
    /// The text that should be rendered.
    public var text = ""
 
    /// The name of the used font.
    public var fontName = "Helvetica Neue"
    ///  This factor determins the font-size. Its a relative value that is multiplied with the image height
    ///  during the process.
    public var intialFontSize = CGFloat(1)
    
    public var transform = CGAffineTransformIdentity

    /// The relative center of the sticker within the image.
    public var center = CGPoint()
    
    /// The relative scale of the sticker within the image.
    public var scale = CGFloat(1.0)
    
    /// The crop-create applied to the input image, so we can adjust the sticker position
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
        
        let stickerImage = createStickerImage()
        
        guard let cgImage = stickerImage.CGImage, filter = CIFilter(name: "CISourceOverCompositing") else {
            return inputImage
        }
        
        let stickerCIImage = CIImage(CGImage: cgImage)
        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(stickerCIImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
    
    public func absolutStickerSizeForImageSize(imageSize: CGSize) -> CGSize {
        let stickerRatio = sticker!.size.height / sticker!.size.width
        if(imageSize.width > imageSize.height) {
            return CGSize(width: self.scale * imageSize.height, height: self.scale * stickerRatio * imageSize.height)
        }
        return CGSize(width: self.scale * imageSize.width, height: self.scale * stickerRatio * imageSize.width)
    }

    
    private func createTextImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        
        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        customParagraphStyle.lineBreakMode = .ByClipping
        let font = UIFont(name: fontName, size: intialFontSize * originalSize.height)

        let textSize = textImageSize()
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        UIGraphicsBeginImageContext(textSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: textSize))
        text.drawAtPoint(CGPointZero, withAttributes:  [NSFontAttributeName: font!, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: customParagraphStyle.copy() as! NSParagraphStyle])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func textImageSize() -> CGSize {
        let rect = inputImage!.extent
        let imageSize = rect.size
    
        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        let customParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        customParagraphStyle.lineBreakMode = .ByClipping
        let font = UIFont(name: fontName, size: intialFontSize * originalSize.height)
    
        return text.sizeWithAttributes([NSFontAttributeName: font!, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: customParagraphStyle.copy() as! NSParagraphStyle])
    }
   
    private func createStickerImage() -> UIImage {
        let rect = inputImage!.extent
        let imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        
        if let context = UIGraphicsGetCurrentContext() {
            drawStickerInContext(context, withImageOfSize: imageSize)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func drawStickerInContext(context: CGContextRef, withImageOfSize imageSize: CGSize) {
        CGContextSaveGState(context)
        
        let originalSize = CGSize(width: round(imageSize.width / cropRect.width), height: round(imageSize.height / cropRect.height))
        var center = CGPoint(x: self.center.x * originalSize.width, y: self.center.y * originalSize.height)
        center.x -= (cropRect.origin.x * originalSize.width)
        center.y -= (cropRect.origin.y * originalSize.height)
        
        let size = self.absolutStickerSizeForImageSize(originalSize)
        let imageRect = CGRect(origin: center, size: size)
        
        // Move center to origin
        CGContextTranslateCTM(context, imageRect.origin.x, imageRect.origin.y)
        // Apply the transform
        CGContextConcatCTM(context, self.transform)
        // Move the origin back by half
        CGContextTranslateCTM(context, imageRect.size.width * -0.5, imageRect.size.height * -0.5)
        
        sticker?.drawInRect(CGRect(origin: CGPoint(), size: size))
        CGContextRestoreGState(context)
    }

  }

extension IMGLYTextFilter {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYTextFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.text = (text as NSString).copyWithZone(zone) as! String
        copy.fontName = (fontName as NSString).copyWithZone(zone) as! String
        copy.intialFontSize = intialFontSize
        copy.cropRect = cropRect
        copy.center = center
        copy.scale = scale
        copy.transform = transform
        #if os(iOS)
        copy.color = color.copyWithZone(zone) as! UIColor
        #elseif os(OSX)
        copy.color = color.copyWithZone(zone) as! NSColor
        #endif
        
        return copy
    }
}
