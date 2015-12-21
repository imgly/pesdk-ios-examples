//
//  IMGLYStickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public protocol IMGLYStickersDataSourceProtocol {
    /// The total count of all available stickers.
    var stickerCount: Int { get }

    /// The sticker at the given index.
    func stickerAtIndex(index: Int) -> IMGLYSticker
}


@objc public class IMGLYStickersDataSource: NSObject, IMGLYStickersDataSourceProtocol {

    private let stickers: [IMGLYSticker]

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

        stickers = stickerFiles.map { (file: String) -> IMGLYSticker? in
            if let image = UIImage(named: file, inBundle: NSBundle(forClass: IMGLYStickersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: file + "_thumbnail", inBundle: NSBundle(forClass: IMGLYStickersDataSource.self), compatibleWithTraitCollection: nil)
                return IMGLYSticker(image: image, thumbnail: thumbnail)
            }

            return nil
            }.filter { $0 != nil }.map { $0! }

        super.init()
    }

    /**
     Creates a custom datasource offering the given stickers.
    */
    public init(stickers: [IMGLYSticker]) {
        self.stickers = stickers
        super.init()
    }

    // MARK:- IMGLYStickersDataSource

    public var stickerCount: Int {
        get {
            return stickers.count
        }
    }

    public func stickerAtIndex(index: Int) -> IMGLYSticker {
        return stickers[index]
    }
}
