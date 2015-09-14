//
//  IMGLYStickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYStickersDataSourceDelegate: class, UICollectionViewDataSource {
    var stickers: [IMGLYSticker] { get }
}

public class IMGLYStickersDataSource: NSObject, IMGLYStickersDataSourceDelegate {
    public let stickers: [IMGLYSticker]
    
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
    
    public init(stickers: [IMGLYSticker]) {
        self.stickers = stickers
        super.init()
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! IMGLYStickerCollectionViewCell
        
        cell.imageView.image = stickers[indexPath.row].thumbnail ?? stickers[indexPath.row].image
        
        return cell
    }
}
