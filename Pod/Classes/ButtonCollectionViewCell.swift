//
//  ButtonCollectionViewCell.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

// TODO: Public?
class ButtonCollectionViewCell: ImageCaptionCollectionViewCell {

    // MARK: - ImageCaptionCollectionViewCell
    
    override var imageSize: CGSize {
        return CGSize(width: 44, height: 44)
    }
}
