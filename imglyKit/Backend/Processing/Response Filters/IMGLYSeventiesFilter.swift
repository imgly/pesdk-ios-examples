//
//  IMGLYSeventiesFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSeventiesFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Seventies")
        self.imgly_displayName = "70s"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Seventies
    }
}
