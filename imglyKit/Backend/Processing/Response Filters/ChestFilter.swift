//
//  ChestFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYChestFilter) public class ChestFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Chest")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ChestFilter: EffectFilter {
    public var displayName: String {
        return "Chest"
    }

    public var filterType: FilterType {
        return .Chest
    }
}
