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

    /// A `BorderStore` that is used by this class. It defaults to the `sharedStore`.
    public var borderStore: BorderStoreProtocol = BorderStore.sharedStore

    /// A `ImageStore` that is used by this class. It defaults to the `sharedStore`.
    public var imageStore: ImageStore = ImageStore.sharedStore

    private var borders: [Border]? = nil

    // MARK: Init

    private func getBorders(completionBlock: ([Border]?, NSError?) -> Void) {
        if let borders = self.borders {
            completionBlock(borders, nil)
        } else {
            borderStore.get("http://localhost:8000/borders.json", completionBlock: { records, error in
                if let records = records {
                    let borderGroup = dispatch_group_create()
                    self.borders = [Border]()
                    var lastError: NSError? = nil
                    for record in records {
                        dispatch_group_enter(borderGroup)
                        self.borderForRecord(record, completionBlock: { border, error in
                            if let border = border {
                                self.borders?.append(border)
                            } else {
                                lastError = error
                            }
                            dispatch_group_leave(borderGroup)
                        })
                    }
                    dispatch_group_notify(borderGroup, dispatch_get_main_queue(), { () -> Void in
                        if let lastError = lastError {
                            completionBlock(nil, lastError)
                        } else {
                            completionBlock(self.borders, nil)
                        }
                    })
                } else {
                    completionBlock(nil, error)
                }
            })
        }
    }

    /**
     Creates a default datasource offering all available stickers.
     */
    override init() {
        super.init()
    }

    // MARK: - StickersDataSource

    /**
    The count of borders.

    - parameter completionBlock: A completion block.
    */
    public func borderCount(ratio: Float, tolerance: Float, completionBlock: (Int, NSError?) -> Void) {
        getBorders({ borders, error in
            if let borders = borders {
                self.borders = borders

                completionBlock(borders.count, nil)
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
    public func borderAtIndex(index: Int, ratio: Float, tolerance: Float, completionBlock: BorderCompletionBlock) {
        getBorders({ borders, error in
            if let borders = self.borders {
                completionBlock(borders[index], nil)
            } else {
                completionBlock(nil, error)
            }
        })
    }

    private func borderForRecord(record: BorderInfoRecord, completionBlock: (Border?, NSError?) -> Void) {
        let imageGroup = dispatch_group_create()

        imageStore.get(record.thumbnailURL) { (image, error) -> Void in
            guard let thumbnail = image else {
                completionBlock(nil, error)
                return
            }
            let border = Border(thumbnail: thumbnail, label: record.label)
            var lastError: NSError? = nil
            for info in record.imageInfos {
                dispatch_group_enter(imageGroup)
                self.imageStore.get(info.url) { (image, error) -> Void in
                    if let image = image {
                        border.addImage(image, ratio: info.ratio)
                    } else {
                        lastError = error
                    }
                    dispatch_group_leave(imageGroup)
                }
            }
            dispatch_group_notify(imageGroup, dispatch_get_main_queue(), { () -> Void in
                if let lastError = lastError {
                    completionBlock(nil, lastError)
                } else {
                    completionBlock(border, nil)
                }
            })
        }
    }
}
