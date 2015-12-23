//
//  PlateFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYPlateFilter) public class PlateFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Plate")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PlateFilter: EffectFilter {
    public var displayName: String {
        return "Plate"
    }

    public var filterType: FilterType {
        return .Plate
    }
}
