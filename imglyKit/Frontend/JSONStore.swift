//
//  JSONStore.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 12/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

class JSONStore: NSObject {
    static private var store: [String : NSData?] = [ : ]

    static private func httpGet(request: NSURLRequest!, callback: (NSData?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

    static func get(url: String) {
//        let request = NSMutableURLRequest(URL: NSURL(string: "http://localhost:8000/borders.json")!)
        if let data = store[url] {
            print("got it", data)
        } else {
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            httpGet(request) {
                (data, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    if let data = data {
                        store[url] = data
                        print(data)
                    }
                }
            }
        }
    }
}
