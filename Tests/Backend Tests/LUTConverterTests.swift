//
//  LUTConverterTests.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 04/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import XCTest

class LUTConverterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleColorCubeGenerationPerformance() {
        self.measureBlock {
            for _ in 0..<10 {
                let _ = LUTToNSDataConverter.colorCubeDataFromLUT("Identity")
            }
        }
    }

    func testInterpolatedColorCubeGenerationPerformance() {
        self.measureBlock {
            for _ in 0..<10 {
                let _ = LUTToNSDataConverter.colorCubeDataFromLUTNamed("K1", interpolatedWithIdentityLUTNamed: "Identity", withIntensity: 0.5, cacheIdentityLUT: false)
            }
        }
    }

}
