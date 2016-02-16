//
//  RequestServiceJSONMock.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

/**
 *  This mock returns a border-JSON document.
 */
@objc(IMGLYRequestServiceJSONMock) public class RequestServiceJSONMock: NSObject, RequestServiceProtocol {

    public var callCounter = 0

    /**
     :nodoc:
     */
    public func get(url: String, callback: (NSData?, NSError?) -> Void) {
        let json = "{\r\n   \"version\":\"1.0\",\r\n   \"borders\":[\r\n      {\r\n        \"name\":\"border0\",\r\n        \"label\":\"Black wood border\",\r\n        \"thumbnail_url\":\"http://1_thumb\",\r\n        \"images\": {\r\n          \"1.0\":\"http://1_1\",\r\n          \"4.0/6.0\":\"http://1_4_6\",\r\n          \"6.0/4.0\":\"http://1_6_4\"\r\n        }\r\n      },\r\n      {\r\n        \"name\":\"border1\",\r\n        \"label\":\"Brown wood border\",\r\n        \"thumbnail_url\":\"http://2_thumb\",\r\n        \"images\": {\r\n          \"1.0\":\"http://2_1\",\r\n          \"4.0/6.0\":\"http://2_4_6\",\r\n          \"6.0/4.0\":\"http://2_6_4\"\r\n        }\r\n      }\r\n   ]\r\n}\r\n"
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        callCounter++
        callback(data, nil)
    }
}
