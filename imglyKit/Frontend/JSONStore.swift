//
//  JSONStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

class JSONStore: NSObject {
    static private var store: String? = nil

    static func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if let error = error {
                callback("", error.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                store = result as String
                callback(result as String, nil)
            }
        }
        task.resume()
    }

    static func doIt() {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/borders.json")!)
        if let store = store {
            print("got it", store)
        } else {
            httpGet(request) {
                (data, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    print(data)
                }
            }
        }
    }
}
