//
//  IMGLYAD1920Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYAD1920Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "AD1920")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYAD1920Filter: EffectFilterType {
    public var displayName: String {
        return "AD1920"
    }

    public var filterType: IMGLYFilterType {
        return .AD1920
    }
}
