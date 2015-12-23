//
//  IMGLYPlateFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPlateFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Plate")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYPlateFilter: EffectFilterType {
    public var displayName: String {
        return "Plate"
    }

    public var filterType: IMGLYFilterType {
        return .Plate
    }
}
