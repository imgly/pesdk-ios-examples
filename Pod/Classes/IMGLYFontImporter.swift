//
//  IMGLYFontImporter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 09/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText

/**
  Provides functions to import font added as resource. It also registers them,
  so that the application can load them like any other pre-installed font.
*/
public class IMGLYFontImporter {
    private static var fontsRegistered = false
    
    /**
    Imports all fonts added as resource. Supported formats are TTF and OTF.
    */
    public func importFonts() {
        if !IMGLYFontImporter.fontsRegistered {
            importFontsWithExtension("ttf")
            importFontsWithExtension("otf")
            IMGLYFontImporter.fontsRegistered = true
        }
    }
    
    private func importFontsWithExtension(ext: String) {
        let paths = NSBundle(forClass: self.dynamicType).pathsForResourcesOfType(ext, inDirectory: nil)
        for fontPath in paths as! [String] {
            let data: NSData? = NSFileManager.defaultManager().contentsAtPath(fontPath)
            var error: Unmanaged<CFError>?
            var provider = CGDataProviderCreateWithCFData(data as! CFDataRef)
            var font = CGFontCreateWithDataProvider(provider)
            if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
                println("Failed to register font, error: \(error)")
                return
            }
        }
    }
}