//
//  IMGLYWinterFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYWinterFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Winter")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYWinterFilter: EffectFilterType {
    public var displayName: String {
        return "Winter"
    }

    public var filterType: IMGLYFilterType {
        return .Winter
    }
}
