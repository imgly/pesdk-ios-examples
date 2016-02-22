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

    public var jsonParser: JSONParserProtocol = JSONParser()

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
                    do {
                        try self.store[url] = self.jsonParser.parseJSON(dict)
                    } catch JSONParserError.IllegalBorderHash {
                        completionBlock(nil, NSError(info: Localize("Illegal border hash")))
                    } catch JSONParserError.IllegalImageRecord(let recordName) {
                        completionBlock(nil, NSError(info: Localize("Illegal image record") + " .Tag: \(recordName)"))
                    } catch JSONParserError.IllegalImageRatio(let recordName) {
                        completionBlock(nil, NSError(info: Localize("Illegal image ratio" ) + " .Tag: \(recordName)"))
                    } catch JSONParserError.BorderNodeNoDictionary {
                        completionBlock(nil, NSError(info: Localize("Border node not holding a dictionaty")))
                    } catch JSONParserError.BorderArrayNotFound {
                        completionBlock(nil, NSError(info: Localize("Border node not found, or not holding an array")))
                    } catch {
                         completionBlock(nil, NSError(info: Localize("Unknown error")))
                    }
                    completionBlock(self.store[url], nil)
                } else {
                    completionBlock(nil, error)
                }
            })
        }
    }
}
