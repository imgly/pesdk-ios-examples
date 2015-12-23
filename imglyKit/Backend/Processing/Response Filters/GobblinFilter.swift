//
//  GobblinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class GoblinFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Goblin")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension GoblinFilter: EffectFilter {
    public var displayName: String {
        return "Goblin"
    }

    public var filterType: FilterType {
        return .Goblin
    }
}
