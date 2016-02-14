//
//  JSONStoreTest.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 14/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import XCTest

class JSONStoreTest: XCTestCase {

    var jsonStore: JSONStore?

    override func setUp() {
        super.setUp()
        jsonStore = JSONStore()
        jsonStore!.requestService = RequestServiceJSONMock()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
     Ensure the JSONStore uses the request service and returns a NSDictionary.
     */
    func testVersion() {
        // swiftlint:disable force_cast
        jsonStore?.get("") { (dict, error) -> Void in
            if let dict = dict {
                XCTAssert(dict["version"] as! String == "1.0", "Version tag not found or valid")
            } else {
                XCTAssert(false, "JSONStore must return a NSDictionary")
            }
        }
        // swiftlint:enable force_cast
    }
}
