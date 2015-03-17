//
//  IMGLYPhotoProcessor.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

/**
All types of response-filters.
*/
@objc public enum IMGLYFilterType: Int {
    case None,
    K1,
    K2,
    K6,
    KDynamic,
    Fridge,
    Breeze,
    Orchid,
    Chest,
    Front,
    Fixie,
    X400,
    BW,
    AD1920,
    Lenin,
    Quozi,
    Pola669,
    PolaSX,
    Food,
    Glam,
    Celsius,
    Texas,
    Lomo,
    Gobblin,
    Sin,
    Mellow,
    Sunny,
    A15,
    Soft,
    Blues,
    Elder,
    Sunset,
    Evening,
    Steel,
    Seventies,
    HighContrast,
    BlueShadows,
    Highcarb,
    Eighties,
    Colorful,
    Lomo100,
    Pro400,
    Twilight,
    CottonCandy,
    Mono3200,
    BlissfulBlue,
    Pale,
    Settled,
    Cool,
    Litho,
    Prelude,
    Nepal,
    Ancient,
    Pitched,
    Lucid,
    Creamy,
    Keen,
    Tender,
    Bleached,
    BleachedBlue,
    Fall,
    Winter,
    SepiaHigh,
    Summer,
    Classic,
    NoGreen,
    Neat,
    Plate
}

@objc public class IMGLYPhotoProcessor {
    public class func processWithCIImage(image: CIImage, filters: [CIFilter]) -> CIImage? {
        if filters.count == 0 {
            return image
        }
        var currentImage:CIImage? = image
        var activeInputs:[CIImage] = []
        
        for filter:CIFilter in filters {
            filter.setValue(currentImage!, forKey:kCIInputImageKey)
            currentImage = filter.outputImage
            if currentImage == nil {
                return nil
            }
        }
        if CGRectIsEmpty(currentImage!.extent()) {
            return nil
        }
        return currentImage
    }
    
    public class func processWithUIImage(image: UIImage, filters: [CIFilter]) -> UIImage? {
        var imageOrientation = image.imageOrientation
        var filtredCIImage:CIImage? = processWithCIImage(CIImage(image: image), filters: filters)
        var filtredCGImage = CIContext(options: nil).createCGImage(filtredCIImage!, fromRect: filtredCIImage!.extent())
        return UIImage(CGImage: filtredCGImage, scale: 1.0, orientation: imageOrientation)
    }
}