//
//  JSONStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

/**
 The `JSONStore` provides methods to retrieve JSON data from any URL.
 */
@objc(IMGLYJSONStoreProtocol) public protocol JSONStoreProtocol {
    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    func get(url: String, completionBlock: (NSDictionary?, NSError?) -> Void)
}

/**
 The `JSONStore` class provides methods to retrieve JSON data from any URL.
 It also caches the data due to efficiency.
 */
@objc(IMGLYJSONStore) public class JSONStore: NSObject, JSONStoreProtocol {

    /// A shared instance for convenience.
    public static let sharedStore = JSONStore()

    /// A service that is used to perform http get requests.
    public var requestService: RequestServiceProtocol = RequestService()

    private var store: [String : NSDictionary?] = [ : ]

    /**
     Retrieves JSON data from the specified URL.

     - parameter url:             A valid URL.
     - parameter completionBlock: A completion block.
     */
    public func get(url: String, completionBlock: (NSDictionary?, NSError?) -> Void) {
        if let dict = store[url] {
            completionBlock(dict, nil)
        } else {
            startJSONRequest(url, completionBlock: completionBlock)
        }
    }

    private func startJSONRequest(url: String, completionBlock: (NSDictionary?, NSError?) -> Void) {
        requestService.get(url) {
            (data, error) -> Void in
            if error != nil {
                completionBlock(nil, error)
            } else {
                if let data = data {
                    if let dict = self.dictionaryFromData(data) {
                        self.store[url] = dict
                        completionBlock(dict, nil)
                    }
                }
            }
        }

    }

    private func dictionaryFromData(data: NSData) -> NSDictionary? {
        do {
            print(String(data: data, encoding: NSASCIIStringEncoding))
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let dict = jsonObject as? NSDictionary {
                return dict
            }
        } catch _ {
            return nil
        }
        return nil
    }
}
