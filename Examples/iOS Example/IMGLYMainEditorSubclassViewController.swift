//
//  IMGLYMainEditorSubclassViewController.swift
//  iOS Example
//
//  Created by Malte Baumann on 25/11/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import imglyKit
import UIKit

class IMGLYMainEditorSubclassViewController: IMGLYMainEditorViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SUBCLASS!")
    }
    
    internal override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
}
