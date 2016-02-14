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

    /// A shared instance fore convenience.
    public static let sharedStore = JSONStore()

    private var store: [String : NSDictionary?] = [ : ]

    private func httpGet(request: NSURLRequest!, callback: (NSData?, NSError?) -> Void) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session  = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

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
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        httpGet(request) {
            (data, error) -> Void in
            if error != nil {
                completionBlock(nil, error)
            } else {
                print("1", data)
                if let data = data {
                    print("3")
                    if let dict = self.dictionaryFromData(data) {
                        print("2", dict)
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
