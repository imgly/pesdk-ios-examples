//
//  IMGLYFilter.swift
//  imglyKit
//
//  Here we define Source Filters. These Should be the first filter in a chain.
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit


/**
  A base class for a source-filter. These will be used in a filter chain, to hand over the input image
  to the following filters.
*/
public class IMGLYSourceFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.displayName = "source"
    }
    
    override public init() {
        super.init()
        self.displayName = "source"
    }

    override public var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            return inputImage!
        }
    }
}

/**
  A source filter that takes a video-frame as input.
*/
public class IMGLYSourceVideoFilter : IMGLYSourceFilter {
    public func customAttributes() -> [String:AnyObject] {
        return [ kCIAttributeFilterDisplayName : "Input Video",
            kCIAttributeFilterCategories : [kCICategoryVideo] ];
    }
}

/**
  A source filter that takes a photo as input.
*/
public class IMGLYSourcePhotoFilter : IMGLYSourceFilter {
    public func customAttributes() -> [String:AnyObject] {
        return [ kCIAttributeFilterDisplayName : "Input Photo",
            kCIAttributeFilterCategories : [kCICategoryStillImage]];
    }
}
