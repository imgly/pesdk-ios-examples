//
//  IMGLYHighContrastFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYHighContrastFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "HighContrast")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYHighContrastFilter: EffectFilterType {
    public var displayName: String {
        return "Hicon"
    }

    public var filterType: IMGLYFilterType {
        return .HighContrast
    }
}
