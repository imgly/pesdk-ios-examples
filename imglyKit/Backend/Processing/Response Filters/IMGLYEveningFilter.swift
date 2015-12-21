//
//  IMGLYColorPhotoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYEveningFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Evening")
        self.imgly_displayName = "Evening"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Evening
    }
}
