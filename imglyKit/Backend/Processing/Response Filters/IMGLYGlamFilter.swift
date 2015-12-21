//
//  IMGLYGlamFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYGlamFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Glam")
        self.imgly_displayName = "Glam"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Glam
        }
    }
}
