//
//  CGVectorExtension.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 22/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

func * (lhs: CGFloat, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs * rhs.dx, dy: lhs * rhs.dy)
}

func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

func + (lhs: CGVector, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.dx + rhs.x, y: lhs.dy + rhs.y)
}

func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

func - (lhs: CGVector, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.dx - rhs.x, y: lhs.dy - rhs.y)
}

func - (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}

extension CGVector {
    init(startPoint: CGPoint, endPoint: CGPoint) {
        dx = endPoint.x - startPoint.x
        dy = endPoint.y - startPoint.y
    }

    func normalizedVector() -> CGVector {
        var copy = self
        copy.normalize()
        return copy
    }

    mutating func normalize() {
        let length = sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
    }
}
