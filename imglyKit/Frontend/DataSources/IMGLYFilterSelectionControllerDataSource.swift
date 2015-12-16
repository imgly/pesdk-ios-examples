//
//  IMGLYFilterSelectionDataSource.swift
//  imglyKit
//
//  Created by Malte Baumann on 15/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 This protocol describes an object that can act as
 a datasource for an `IMGLYFilterSelectionController`.
*/
@objc public protocol IMGLYFilterSelectionControllerDataSourceProtocol {
    
    /// The total count of all available filters.
    var filterCount: Int { get }
    
    /// The filter type at the given index.
    func filterTypeAtIndex(index: Int) -> IMGLYFilterType
    
    /**
     The sample image to be used at the given index.
     
     - parameter index: The filters index
     - returns: A UIImage thats used as a placeholder. This
     image is processed according to the filter type and
     then used as a preview image in the bottom drawer.
    */
    func previewImageForFilterAtIndex(index: Int) -> UIImage
    
    /// The title of the filter at the given index.
    func titleForFilterAtIndex(index: Int) -> String
    
    /// An image thats used to indicate an activated filter.
    func selectedImageForFilterAtIndex(index: Int) -> UIImage
    
    /**
     The initial intensity that is applied, when the filter
     at the given index is selected.
     
     - returns: A value between 0 and 1.
    */
    func initialIntensityForFilterAtIndex(index: Int) -> Float
}

/**
 This class uses default values to act as a datasource for
 a `IMGLYFilterSelectionController`. The available filter types
 can be set in the initializer. Per default all filters
 currently included with the SDK are offered.
*/
@objc public class IMGLYFilterSelectionControllerDataSource: NSObject, IMGLYFilterSelectionControllerDataSourceProtocol {
    
    let InitialFilterIntensity = Float(0.75)
    
    private var availableFilterTypes: [IMGLYFilterType] = IMGLYInstanceFactory.availableFilterList
    
    // MARK: Init
    
    /**
    Creates a default datasource offering all available filters.
    */
    public override init() {
        super.init()
    }
    
    /**
     Creates a default datasource offering the given filters in their
     order within the array.
     - Parameter availableActionTypes: An array of supported `IMGLYMainEditorActionType`s
     */
    public convenience init(availableFilters: [IMGLYFilterType]) {
        self.init()
        self.availableFilterTypes = availableFilters
    }
    
    /// This initializer should only be used in Objective-C. It expects an NSArray of NSNumbers that wrap
    /// the integer value of IMGLYFilterType.
    public convenience init(availableFilters: [NSNumber]) {
        let castedFilters = availableFilters.map { IMGLYFilterType(rawValue: $0.integerValue) }.filter { $0 != nil }.map { $0! }
        self.init(availableFilters: castedFilters)
    }
    
    // MARK: IMGLYFilterSelectionDataSourceProtocol

    public var filterCount: Int {
        return self.availableFilterTypes.count
    }
    
    public func filterTypeAtIndex(index: Int) -> IMGLYFilterType {
        return availableFilterTypes[index]
    }
    
    public func previewImageForFilterAtIndex(index: Int) -> UIImage {
        let bundle = NSBundle(forClass: IMGLYFilterSelectionControllerDataSource.self)
        return UIImage(named: "nonePreview", inBundle: bundle, compatibleWithTraitCollection:nil)!
    }
    
    public func titleForFilterAtIndex(index: Int) -> String {
        return IMGLYInstanceFactory.effectFilterWithType(availableFilterTypes[index]).imgly_displayName!
    }
    
    public func selectedImageForFilterAtIndex(index: Int) -> UIImage {
        let bundle = NSBundle(forClass: IMGLYFilterSelectionControllerDataSource.self)
        return UIImage(named: "icon_tick", inBundle: bundle, compatibleWithTraitCollection:nil)!
    }
    
    public func initialIntensityForFilterAtIndex(index: Int) -> Float {
        return InitialFilterIntensity
    }
}
