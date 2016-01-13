//
//  UIViewExtensionTests.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 13/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import XCTest
@testable import imglyKit

class UIViewExtensionTests: XCTestCase {

    var view: UIView!

    override func setUp() {
        super.setUp()

        // Recreate view
        view = UIView()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddConstraint() {
        let constraint1 = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)

        view.addConstraint(constraint1, forKey: "test1")
        view.addConstraint(constraint2, forKey: "test2")

        XCTAssert(view.constraints.contains(constraint1))
        XCTAssert(view.constraints.contains(constraint1))

        XCTAssert(view.hasConstraintForKey("test1"))
        XCTAssert(view.hasConstraintForKey("test2"))
        XCTAssert(!view.hasConstraintForKey("test3"))
    }

    func testAddConstraints() {
        let constraint1 = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)

        view.addConstraints([constraint1, constraint2], forKey: "test")
        XCTAssertEqual([constraint1, constraint2], view.constraints)
        XCTAssertNotNil(view.constraintsForKey("test"))

        if let constraints = view.constraintsForKey("test") {
            XCTAssertEqual([constraint1, constraint2], constraints)
        }
    }

    func testRemoveConstraints() {
        let constraint1 = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)

        view.addConstraints([constraint1, constraint2], forKey: "test")
        view.removeAllConstraintsForKey("test")

        XCTAssertNil(view.constraintsForKey("test"))
        XCTAssert(view.constraints.count == 0)
    }

    func testClearConstraints() {
        let constraint1 = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        let constraint2 = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)

        view.addConstraints([constraint1, constraint2], forKey: "test")
        view.clearAllConstraintsForKey("test")

        XCTAssertNil(view.constraintsForKey("test"))
        XCTAssertEqual([constraint1, constraint2], view.constraints)
    }

}
