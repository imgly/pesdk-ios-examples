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
        let stickerFiles = [
            "glasses_nerd",
            "glasses_normal",
            "glasses_shutter_green",
            "glasses_shutter_yellow",
            "glasses_sun",
            "hat_cap",
            "hat_party",
            "hat_sherrif",
            "hat_zylinder",
            "heart",
            "mustache_long",
            "mustache1",
            "mustache2",
            "mustache3",
            "pipe",
            "snowflake",
            "star"
        ]

        stickers = stickerFiles.flatMap { (file: String) -> Sticker? in
            if let image = UIImage(named: file, inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: file + "_thumbnail", inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil)
                return Sticker(image: image, thumbnail: thumbnail)
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

    // MARK:- StickersDataSource

    public var stickerCount: Int {
        get {
            return stickers.count
        }
    }

    public func stickerAtIndex(index: Int) -> Sticker {
        return stickers[index]
    }
}
