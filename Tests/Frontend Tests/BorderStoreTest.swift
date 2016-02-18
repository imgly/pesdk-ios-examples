//
//  BorderStoreTest.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import XCTest

class BorderStoreTest: XCTestCase {

    var jsonStore: JSONStore?
    var borderStore: BorderStore?

    override func setUp() {
        super.setUp()
        jsonStore = JSONStore()
        jsonStore!.requestService = RequestServiceJSONMock()
        borderStore = BorderStore()
        borderStore!.jsonStore = jsonStore!
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRecordCount() {
        borderStore!.get("") { (records, error) -> Void in
            XCTAssertTrue(records!.count == 2)
            XCTAssertNil(error)
        }
    }

    func testRecordBasicInformation() {
        borderStore!.get("") { (records, error) -> Void in
            XCTAssertEqual(records![0].name, "border0")
            XCTAssertEqual(records![0].label, "Black wood border")
            XCTAssertEqual(records![0].thumbnailURL, "http://1_thumb")

            XCTAssertEqual(records![1].name, "border1")
            XCTAssertEqual(records![1].label, "Brown wood border")
            XCTAssertEqual(records![1].thumbnailURL, "http://2_thumb")
            XCTAssertNil(error)
        }
    }

    func testRecordImageInformation() {
        borderStore!.get("") { (records, error) -> Void in
            XCTAssertNil(error)
            XCTAssertEqual(records!.count, 2)

            let images1 = records![0].imageInfos
            XCTAssertNotNil(images1)
            XCTAssertEqual(images1.count, 3)
            if images1.count == 3 {
                XCTAssertEqual(images1[0].ratio, Float(1.0))
                XCTAssertEqual(images1[0].url, "http://1_1")
                XCTAssertEqual(images1[1].ratio, Float(4.0/6.0))
                XCTAssertEqual(images1[1].url, "http://1_4_6")
                XCTAssertEqual(images1[2].ratio, Float(6.0/4.0))
                XCTAssertEqual(images1[2].url, "http://1_6_4")
            }

            let images2 = records![1].imageInfos
            XCTAssertNotNil(images2)
            XCTAssertEqual(images2.count, 3)
            if images2.count == 3 {
                XCTAssertEqual(images2[0].ratio, Float(1.0))
                XCTAssertEqual(images2[0].url, "http://2_1")
                XCTAssertEqual(images2[1].ratio, Float(4.0/6.0))
                XCTAssertEqual(images2[1].url, "http://2_4_6")
                XCTAssertEqual(images2[2].ratio, Float(6.0/4.0))
                XCTAssertEqual(images2[2].url, "http://2_6_4")
            }
        }
    }
}
