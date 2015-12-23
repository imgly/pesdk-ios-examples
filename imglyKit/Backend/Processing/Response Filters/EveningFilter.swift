//
//  ColorPhotoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class EveningFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Evening")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension EveningFilter: EffectFilter {
    public var displayName: String {
        return "Evening"
    }

    public var filterType: FilterType {
        return .Evening
    }
}
