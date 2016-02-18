//
//  BorderStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//


import UIKit


/**
 The `JSONStore` provides methods to retrieve JSON data from any URL.
 */
@objc(IMGLYBorderStoreProtocol) public protocol BorderStoreProtocol {
    /**
     Retrieves BorderInfoRecord data, from the JSON located at the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: String, completionBlock: ([BorderInfoRecord]?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency, and performs a sanity check.
 */
@objc(IMGLYBorderStore) public class BorderStore: NSObject, BorderStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = BorderStore()

    /// This store is used to retrieve the JSON data.
    public var jsonStore: JSONStoreProtocol = JSONStore()

    private var store: [String : [BorderInfoRecord]] = [ : ]

    /**
     Retrieves BorderInfoRecord data, from the JSON located at the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: String, completionBlock: ([BorderInfoRecord]?, NSError?) -> Void) {
        if let record = store[url] {
            completionBlock(record, nil)
        } else {
            jsonStore.get(url, completionBlock: { (dict, error) -> Void in
                if let dict = dict {
                    let err = self.parseJSON(url, dict: dict)
                    completionBlock(self.store[url], err)
                } else {
                    completionBlock(nil, error)
                }
            })
        }
    }

    private func parseJSON(url: String, dict: NSDictionary) -> NSError? {
        var records = [BorderInfoRecord]()
        if let borders = dict["borders"] as? NSArray {
            for border in borders {
                if let border = border as? NSDictionary {
                    guard let name = border["name"] as? String,
                        let label = border["label"] as? String,
                        let thumbnailURL = border["thumbnail_url"] as? String,
                        let images = border["images"] as? NSDictionary else {
                            return NSError(info:Localize("error_illegal_bord_hash"))
                    }
                    let record = BorderInfoRecord()
                    record.name = name
                    record.label = label
                    record.thumbnailURL = thumbnailURL
                    for (key, value) in images {
                        let imageInfo = ImageInfoRecord()
                        guard let ratioString = key as? String,
                            let url = value as? String else {
                                return NSError(info:Localize("error_illegal_image_record"))
                        }
                        let expn = NSExpression(format:ratioString)
                        if let ratio = expn.expressionValueWithObject(nil, context: nil) as? Float {
                            imageInfo.ratio = ratio
                        } else {
                            return NSError(info:Localize("error_illegal_image_ratio"))
                        }
                        imageInfo.url = url
                        record.imageInfos.append(imageInfo)
                    }
                    records.append(record)
                } else {
                    return NSError(info:Localize("error_border_no_dictionary"))
                }
            }
        } else {
            return NSError(info:Localize("error_border_array"))
        }
        store[url] = records
        return nil
    }
}
