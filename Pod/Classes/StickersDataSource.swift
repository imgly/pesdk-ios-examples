//
//  StickersDataSource.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc(IMGLYStickersDataSourceDelegate) public protocol StickersDataSourceDelegate: class, UICollectionViewDataSource {
    var stickers: [Sticker] { get }
}

@objc(IMGLYStickersDataSource) public class StickersDataSource: NSObject, StickersDataSourceDelegate {
    public let stickers: [Sticker]
    
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
        
        stickers = stickerFiles.map { file in
            if let image = UIImage(named: file, inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil) {
                let thumbnail = UIImage(named: file + "_thumbnail", inBundle: NSBundle(forClass: StickersDataSource.self), compatibleWithTraitCollection: nil)
                return Sticker(image: image, thumbnail: thumbnail)
            }
            
            return nil
            }.filter { $0 != nil }.map { $0! }
        
        super.init()
    }
    
    init(stickers: [Sticker]) {
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! StickerCollectionViewCell
        
        cell.imageView.image = stickers[indexPath.row].thumbnail ?? stickers[indexPath.row].image
        
        return cell
    }
}
