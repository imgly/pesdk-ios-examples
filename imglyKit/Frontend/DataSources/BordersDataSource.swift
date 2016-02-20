//
//  BordersDataSource.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYBordersDataSourceProtocol) public protocol BordersDataSourceProtocol {
    /// The total count of all available stickers.
    func borderCount(ratio: Float, tolerance: Float, completionBlock: (Int, NSError?) -> Void)

    /// The sticker at the given index.
    func borderAtIndex(index: Int, ratio: Float, tolerance: Float, completionBlock: BorderCompletionBlock)
}

@objc(IMGLYBordersDataSource) public class BordersDataSource: NSObject, BordersDataSourceProtocol {

    private var borders = [Border]()

    // MARK: Init

    /**
    Creates a default datasource offering all available stickers.
    */
    override init() {
        let thumbnail1 = UIImage(named: "blackwood_thumbnail", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_1_1 = UIImage(named: "blackwood1_1", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_4_6 = UIImage(named: "blackwood4_6", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_6_4 = UIImage(named: "blackwood6_4", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1 = Border(thumbnail: thumbnail1, label: "black wood border")

        guard let border1_1 = border1_1_1,
            let border4_6 = border1_4_6,
            let border6_4 = border1_6_4 else {
                super.init()
            return
        }

        border1.addImage(border1_1, ratio: 1.0)
        border1.addImage(border4_6, ratio: 4.0 / 6.0)
        border1.addImage(border6_4, ratio: 6.0 / 4.0)
        borders.append(border1)
        super.init()
    }

    /**
     Creates a custom datasource offering the given borders.
     */
    public init(borders: [Border]) {
        self.borders = borders
        super.init()
    }

    // MARK: - StickersDataSource

    /**
    Gets the count of the borders that have a mathing ratio.
    The ratio comparision can be relaxed using the tolerance.

    - parameter ratio:           The ratio.
    - parameter tolerance:       The tolerance that is used to widen the ratio acceptence.
    - parameter completionBlock: A completion block that receives the results.
    */
    public func borderCount(ratio: Float, tolerance: Float, completionBlock: (Int, NSError?) -> Void) {
        let matchingBorderCount = bordersMatching(ratio, tolerance: tolerance).count
        completionBlock(matchingBorderCount, nil)
    }

    /**
     Gets the matching sticker at index.

     - parameter index:           The index of the border.
     - parameter ratio:           The allowed ratio.
     - parameter tolerance:       The tolerance applied to the ratio.
     - parameter completionBlock: A completion block that receives the results.
     */
    public func borderAtIndex(index: Int, ratio: Float, tolerance: Float, completionBlock: BorderCompletionBlock) {
        let matchingBorders = bordersMatching(ratio, tolerance: tolerance)
        completionBlock(matchingBorders[index], nil)
    }

    private func bordersMatching(ratio: Float, tolerance: Float) -> [Border] {
        var matchingBorders = [Border]()
        for border in borders {
            if let _ = border.imageForRatio(ratio, tolerance: tolerance) {
                matchingBorders.append(border)
            }
        }
        return matchingBorders
    }
}
