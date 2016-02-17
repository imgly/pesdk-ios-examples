//
//  RequestService.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

/**
 *  A request service is out to perform a get request and hand the data over via block.
 */
@objc(IMGLYRequestServiceProtocol) public protocol RequestServiceProtocol {
    func get(url: String, cached: Bool, callback: (NSData?, NSError?) -> Void)
}

/**
 *  The `RequestService` is out to perform a get request and hand the data over via block.
 */
@objc(IMGLYRequestService) public class RequestService: NSObject, RequestServiceProtocol {

    /**
     Performs a get request.

     - parameter url:  A url as `String`.
     - parameter callback: A callback that gets the retieved data or the occured error.
     */
    public func get(url: String, cached: Bool, callback: (NSData?, NSError?) -> Void) {
        if cached {
            getCached(url, callback: callback)
        } else {
            getUncached(url, callback: callback)
        }
    }

    private func getUncached(url: String, callback: (NSData?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session  = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }

    private func getCached(url: String, callback: (NSData?, NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let session  = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            callback(data, error)
        }
        task.resume()
    }
}
