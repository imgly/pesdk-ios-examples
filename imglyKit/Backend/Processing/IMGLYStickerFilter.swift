//
//  IMGLYStickerFilter.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 24/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#if os(iOS)
import UIKit
import CoreImage
#elseif os(OSX)
import AppKit
import QuartzCore
#endif

import CoreGraphics

public class IMGLYStickerFilter: CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage: CIImage?
    
    /// The sticker that should be rendered.
    #if os(iOS)
    public var sticker: UIImage?
    #elseif os(OSX)
    public var sticker: NSImage?
    #endif
    
    /// The transform to apply to the sticker
    public var transform = CGAffineTransformIdentity
    
    /// The relative center of the sticker within the image.
    public var center = CGPoint()
    
    /// The relative size of the sticker within the image.
    public var size = CGSize()
    
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
        
        if sticker == nil {
            return inputImage
        }
        
        var stickerImage = createStickerImage()
        var stickerCIImage = CIImage(CGImage: stickerImage.CGImage)
        var filter = CIFilter(name: "CISourceOverCompositing")
        filter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        filter.setValue(stickerCIImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
    
    #if os(iOS)
    
    private func createStickerImage() -> UIImage {
        let rect = inputImage!.extent()
        let imageSize = rect.size
        UIGraphicsBeginImageContext(imageSize)
        UIColor(white: 1.0, alpha: 0.0).setFill()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        
        let context = UIGraphicsGetCurrentContext()
        drawStickerInContext(context, withImageOfSize: imageSize)
    
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    #elseif os(OSX)
    
    private func createStickerImage() -> NSImage {
        let rect = inputImage!.extent()
        let imageSize = rect.size
        
        let image = NSImage(size: imageSize)
        image.lockFocus()
        NSColor(white: 1, alpha: 0).setFill()
        NSRectFill(CGRect(origin: CGPoint(), size: imageSize))

        let context = NSGraphicsContext.currentContext()!.CGContext
        drawStickerInContext(context, withImageOfSize: imageSize)
        
        image.unlockFocus()
        
        return image
    }
    
    #endif
    
    private func drawStickerInContext(context: CGContextRef, withImageOfSize imageSize: CGSize) {
        CGContextSaveGState(context)
        
        let center = CGPoint(x: self.center.x * imageSize.width, y: self.center.y * imageSize.height)
        let size = CGSize(width: self.size.width * imageSize.width, height: self.size.height * imageSize.height)
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

extension IMGLYStickerFilter: NSCopying {
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = super.copyWithZone(zone) as! IMGLYStickerFilter
        copy.inputImage = inputImage?.copyWithZone(zone) as? CIImage
        copy.sticker = sticker
        copy.center = center
        copy.size = size
        copy.transform = transform
        return copy
    }
}
