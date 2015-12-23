//
//  IMGLYFilterEditorSubclassViewController.swift
//  iOS Example
//
//  Created by Malte Baumann on 23/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import imglyKit
import UIKit

class SampleStickersEditorSubclass: IMGLYStickersEditorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a custom pattern view to the filter editor viewController
        let patternImage = UIImage(named: "sample_pattern")
        let patternView = UIView()
        patternView.translatesAutoresizingMaskIntoConstraints = false
        patternView.backgroundColor = UIColor(patternImage: patternImage!)
        self.view.addSubview(patternView)
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[patternView]|", options: [], metrics: nil, views: [ "patternView": patternView ]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[patternView(==30)]-0-[bottomContainerView]", options: [], metrics: nil, views: [ "patternView": patternView, "bottomContainerView": self.bottomContainerView ]))
    }
}
