//
//  LeninFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class LeninFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Lenin")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension LeninFilter: EffectFilter {
    public var displayName: String {
        return "Lenin"
    }

    public var filterType: FilterType {
        return .Lenin
    }
}
