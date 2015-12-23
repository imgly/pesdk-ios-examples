//
//  HighContrastFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class HighContrastFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "HighContrast")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension HighContrastFilter: EffectFilter {
    public var displayName: String {
        return "Hicon"
    }

    public var filterType: FilterType {
        return .HighContrast
    }
}
