//
//  BordersDataSource.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

public typealias BorderCompletionBlock = (Border?, NSError?) -> (Void)

@objc(IMGLYRemoteBordersDataSource) public class RemoteBordersDataSource: NSObject, BordersDataSourceProtocol, NSURLConnectionDelegate {

    private var borderMap: [String : Border]? = nil

    /// A `JSONStore` that is used by this class. It defaults to the `sharedStore`.
    public var jsonStore: JSONStoreProtocol = JSONStore.sharedStore

    private var metaData: NSArray? = nil

    // MARK: Init

    private func getMetaData(completionBlock: (NSArray?, NSError?) -> Void) {
        if let metaData = metaData {
            completionBlock(metaData, nil)
        } else {
            jsonStore.get("http://localhost:8000/borders.json", completionBlock: { dict, error in
                print(dict)
                if let dict = dict {
                    if let meta = dict["borders"] as? NSArray {
                        self.metaData = meta
                        completionBlock(meta, nil)
                    } else {
                        completionBlock(nil, error)
                    }
                }
            })
        }
    }

    /**
    Creates a default datasource offering all available stickers.
    */
    override init() {
/*        let borderFilesAndLabels = [
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
        }*/
        super.init()
    }

    // MARK: - StickersDataSource

    /**
    The count of borders.

    - parameter completionBlock: A completion block.
    */
    public func borderCount(completionBlock: (Int, NSError?) -> Void) {
        getMetaData({ meta, error in
            if let meta = meta {
                self.metaData = meta
                completionBlock(meta.count, nil)
            } else {
                completionBlock(0, error)
            }
        })
    }

    /**
    Retrieves a the border at the given index.

     - parameter index:           A index.
     - parameter completionBlock: A completion block.
     */
    public func borderAtIndex(index: Int, completionBlock: BorderCompletionBlock) {
        getMetaData({ meta, error in
            if let meta = meta {
                if let entry = meta[index] as? [String : String] {
                    self.borderForMetaEntry(entry, completionBlock: { border, error in
                        completionBlock(border, error)
                    })
                } else {
                    completionBlock(nil, nil)
                }
            } else {
                completionBlock(nil, error)
            }
        })
    }

    private func borderForMetaEntry(entry: [String : String], completionBlock: (Border?, NSError?) -> Void) {
        if let image = UIImage(named: "glasses_nerd", inBundle: NSBundle(forClass: BordersDataSource.self), compatibleWithTraitCollection: nil) {
            let border = Border(image: image, thumbnail: image, label: "label", ratio: 1.0, url: "")
            completionBlock(border, nil)
        } else {
            completionBlock(nil, nil)
        }
    }
}
