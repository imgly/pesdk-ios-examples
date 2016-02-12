//
//  BordersDataSource.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

public typealias BorderCompletionBlock = (Border?) -> (Void)

@objc(IMGLYRemoteBordersDataSource) public class RemoteBordersDataSource: NSObject, BordersDataSourceProtocol, NSURLConnectionDelegate {

    private let borders: [Border]

    lazy var data = NSMutableData()
    // MARK: Init

    func startConnection() {
        JSONStore.get("http://localhost:8000/borders.json")
    }


    /**
    Creates a default datasource offering all available stickers.
    */
    override init() {
        let borderFilesAndLabels = [
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

        borders = borderFilesAndLabels.flatMap { fileAndLabel -> Border? in
            if let image = UIImage(named: fileAndLabel.0, inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: fileAndLabel.0 + "_thumbnail", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil)
                let label = fileAndLabel.1
                return Border(image: image, thumbnail: thumbnail, label: label, ratio: 1.0, url: "")
            }

            return nil
        }

        super.init()
    }

    /**
     Creates a custom datasource offering the given stickers.
     */
    public init(borders: [Border]) {
        self.borders = borders
        super.init()
    }

    // MARK: - StickersDataSource

    public var borderCount: Int {
        get {
            return borders.count
        }
    }

    public func borderAtIndex(index: Int, completionBlock: BorderCompletionBlock) {
        startConnection()
        completionBlock(borders[index])
    }
}
