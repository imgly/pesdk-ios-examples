//
//  LUTConverter.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 04/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit
import Accelerate

// TODO: Make OS X compatible

@objc(IMGLYLUTConverter) public class LUTConverter: NSObject {
    private static let kDimension = 64
    private static var identityLUT: NSData?

    public class func colorCubeDataFromLUTNamed(name: String, interpolatedWithIdentityLUTNamed identityName: String, withIntensity intensity: Float, cacheIdentityLUT shouldCache: Bool) -> NSData? {
        guard let lut = UIImage(named: name, inBundle: NSBundle(forClass: self), compatibleWithTraitCollection: nil), identityLut = UIImage(named: identityName, inBundle: NSBundle(forClass: self), compatibleWithTraitCollection: nil) else {
            return nil
        }

        return colorCubeDataFromLUTImage(lut, interpolatedWithIdentityLUTImage: identityLut, withIntensity: intensity, cacheIdentityLUT: shouldCache)
    }

    public class func colorCubeDataFromLUT(name: String) -> NSData? {
        guard let lut = UIImage(named: name, inBundle: NSBundle(forClass: self), compatibleWithTraitCollection: nil) else {
            return nil
        }

        return colorCubeDataFromLUTImage(lut)
    }

    public class func colorCubeDataFromLUTImage(lutImage: UIImage, interpolatedWithIdentityLUTImage identityLutImage: UIImage, withIntensity intensity: Float, cacheIdentityLUT shouldCache: Bool) -> NSData? {
        if intensity < 0 || intensity > 1 {
            return nil
        }

        var interpolatedLUT: NSData?

        guard let lut = colorCubeDataFromLUTImage(lutImage) else {
            return nil
        }

        var identityTODORename: NSData?
        if !shouldCache {
            identityTODORename = colorCubeDataFromLUTImage(identityLutImage)
        } else {
            if identityLUT != nil {
                identityTODORename = identityLUT
            } else {
                identityLUT = colorCubeDataFromLUTImage(identityLutImage)
                identityTODORename = identityLUT
            }
        }

        guard let identity = identityTODORename else {
            return nil
        }

        if lut.length != identity.length {
            return nil
        }

        let size = lut.length
        let lutData = UnsafeMutablePointer<Float>(lut.mutableBytes)
        let identityData = UnsafePointer<Float>(identity.bytes)

        var intensityCopy = intensity

//        var data = [Float](count: size, repeatedValue: 0)
//        var data = [Float]()
//        data.reserveCapacity(size)

        vDSP_vsbsm(lutData, 1, identityData, 1, &intensityCopy, lutData, 1, vDSP_Length(size / sizeof(Float)))
        vDSP_vadd(lutData, 1, identityData, 1, lutData, 1, vDSP_Length(size / sizeof(Float)))

        // This is basically Accelerate Framework's way of doing this:
        //        for (int i = 0; i < size / sizeof(float); i++) {
        //            data[i] = (lutData[i] - identityData[i]) * intensity + identityData[i];
        //        }

        interpolatedLUT = NSData(bytesNoCopy: lutData, length: size, freeWhenDone: false)
//        interpolatedLUT = NSData(bytes: &lutData, length: size)

        return interpolatedLUT
    }

    /*
    This method reads an LUT image and converts it to a cube color space representation.
    The resulting data can be used to feed an CIColorCube filter, so that the transformation
    realised by the LUT is applied with a core image standard filter
    */
    public class func colorCubeDataFromLUTImage(lutImage: UIImage) -> NSMutableData? {
        let width = CGImageGetWidth(lutImage.CGImage)
        let height = CGImageGetHeight(lutImage.CGImage)
        let rowNum = height / kDimension
        let columnNum = width / kDimension

        if (width % kDimension != 0) || (height % kDimension != 0) || (rowNum * columnNum != kDimension) {
            NSLog("Invalid image format: \(lutImage)")
            return nil
        }

        guard let cgImage = lutImage.CGImage, bitmapData = rgbaBitmapFromImage(cgImage)?.mutableBytes else {
            return nil
        }

        let bitmap = UnsafeMutablePointer<Float>(bitmapData)

        let size = kDimension * kDimension * kDimension * 4
        let data = UnsafeMutablePointer<Float>.alloc(size)

        var divider = Float(255)
        var bitmapOffset = 0
        var z = 0

        for _ in 0..<rowNum {
            for y in 0..<kDimension {
                let tmp = z

                for _ in 0..<columnNum {
                    let dataOffset = (z * kDimension * kDimension + y * kDimension) * 4

                    vDSP_vsdiv(bitmap.advancedBy(bitmapOffset), 1, &divider, data.advancedBy(dataOffset), 1, vDSP_Length(kDimension * 4))

                    bitmapOffset = bitmapOffset + kDimension * 4
                    z = z + 1
                }

                z = tmp
            }

            z = z + columnNum
        }

        return NSMutableData(bytesNoCopy: data, length: size * sizeof(Float), freeWhenDone: true)
    }

    private class func rgbaBitmapFromImage(image: CGImage) -> NSMutableData? {
        let width = CGImageGetWidth(image)
        let height = CGImageGetHeight(image)

        let bytesPerRow = width * 4
        let bitmapSize = bytesPerRow * height

        let bitmap = UnsafeMutablePointer<UInt8>.alloc(bitmapSize)
        defer {
            bitmap.dealloc(bitmapSize)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGBitmapContextCreate(bitmap, width, height, 8, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue) else {
            return nil
        }

        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height: height), image)
        let convertedBitmap = UnsafeMutablePointer<Float>.alloc(bitmapSize)

        vDSP_vfltu8(bitmap, 1, convertedBitmap, 1, vDSP_Length(bitmapSize))

        return NSMutableData(bytesNoCopy: convertedBitmap, length: bitmapSize * sizeof(Float), freeWhenDone: true)
    }
}
