//
//  StickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYStickersDataSourceProtocol) public protocol StickersDataSourceProtocol {
    /// The total count of all available stickers.
    var stickerCount: Int { get }

    /// The sticker at the given index.
    func stickerAtIndex(index: Int) -> Sticker
}


@objc(IMGLYStickersDataSource) public class StickersDataSource: NSObject, StickersDataSourceProtocol {

    private let stickers: [Sticker]

    // MARK: Init

    /**
     Creates a default datasource offering all available stickers.
    */
    override init() {
        let stickerFilesAndLabels = [
            ("glasses_nerd", "Brown glasses"),
            ("glasses_normal", "Black glasses"),
            ("glasses_shutter_green", "Green glasses"),
            ("glasses_shutter_yellow", "Yellow glasses"),
            ("glasses_sun", "Sunglasses"),
            ("hat_cap", "Blue and white cap"),
            ("hat_party", "White and red party hat"),
            ("hat_sherrif", "Sherrif hat"),
            ("hat_zylinder", "Black high hat"),
            ("heart", "Red heart"),
            ("mustache_long", "Long black mustache"),
            ("mustache1", "Brown mustache"),
            ("mustache2", "Black mustache"),
            ("mustache3", "Brown mustache"),
            ("pipe", "Pipe"),
            ("snowflake", "Snowflake"),
            ("star", "Star")
        ]

        stickers = stickerFilesAndLabels.flatMap { fileAndLabel -> Sticker? in
            if let image = UIImage(named: fileAndLabel.0, inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: fileAndLabel.0 + "_thumbnail", inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil)
                let label = fileAndLabel.1
                return Sticker(image: image, thumbnail: thumbnail, label: label)
            }

            return nil
        }

        super.init()
    }

    /**
     Creates a custom datasource offering the given stickers.
    */
    public init(stickers: [Sticker]) {
        self.stickers = stickers
        super.init()
    }

    // MARK: - StickersDataSource

    public var stickerCount: Int {
        get {
            return stickers.count
        }
    }

    public func stickerAtIndex(index: Int) -> Sticker {
        return stickers[index]
    }
}
