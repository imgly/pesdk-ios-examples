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
    func borderCount(completionBlock: (Int, NSError?) -> Void)

    /// The sticker at the given index.
    func borderAtIndex(index: Int, completionBlock: BorderCompletionBlock)
}


@objc(IMGLYBordersDataSource) public class BordersDataSource: NSObject, BordersDataSourceProtocol {

    private var borders = [Border]()

    // MARK: Init

    /**
    Creates a default datasource offering all available stickers.
    */
    override init() {

        let thumbnail1 = UIImage(named: "blackwood_thumbnail", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_1_1 =  UIImage(named: "blackwood1_1", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_4_6 =  UIImage(named: "blackwood4_6", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
        let border1_6_4 =  UIImage(named: "blackwood6_4", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
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

    public func borderCount(completionBlock: (Int, NSError?) -> Void) {
        completionBlock(borders.count, nil)
    }

    public func borderAtIndex(index: Int, completionBlock: BorderCompletionBlock) {
        completionBlock(borders[index], nil)
    }
}
