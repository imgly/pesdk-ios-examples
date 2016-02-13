//
//  JSONStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

class JSONStore: NSObject {
    static private var store: [String : NSDictionary?] = [ : ]

    static private func httpGet(request: NSURLRequest!, callback: (NSData?, NSError?) -> Void) {
    //    let session = NSURLSession.sharedSession()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session  = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

    static func get(url: String) {
        if let data = store[url] {
            print("got it", data)
        } else {
            startJSONRequest(url)
        }
    }

    static func startJSONRequest(url: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        httpGet(request) {
            (data, error) -> Void in
            if error != nil {
                print(error)
            } else {
                if let data = data {
                    if let dict = dictionaryFromData(data) {
                        store[url] = dict
                        print(dict)
                    }
                }
            }
        }

    }

    static func dictionaryFromData(data: NSData) -> NSDictionary? {
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
