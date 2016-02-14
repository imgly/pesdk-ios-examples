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

    /**
     :nodoc:
     */
    public func get(url: String, callback: (NSData?, NSError?) -> Void) {
        let json = "{\r\n   \"version\":\"1.0\",\r\n   \"borders\":[\r\n      {\r\n        \"name\":\"border0\",\r\n        \"label\":\"Black wood border\",\r\n        \"thumbnail_url\":\"http://someURL\",\r\n        \"1to1_url\":\"http://someURL\",\r\n        \"4to6_url\":\"http://someURL\",\r\n        \"6to4_url\":\"http://someURL\"\r\n      },\r\n      {\r\n        \"name\":\"border1\",\r\n        \"label\":\"Brown wood border\",\r\n        \"thumbnail_url\":\"http://someURL\",\r\n        \"1to1_url\":\"http://someURL\",\r\n        \"4to6_url\":\"http://someURL\",\r\n        \"6to4_url\":\"http://someURL\"\r\n      }\r\n   ]\r\n}"
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        callback(data, nil)
    }
}
