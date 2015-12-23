//
//  IMGLYLomoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYLomoFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Lomo")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYLomoFilter: EffectFilterType {
    public var displayName: String {
        return "Lomo"
    }

    public var filterType: IMGLYFilterType {
        return .Lomo
    }
}
