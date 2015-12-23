//
//  Pola669Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYPola669Filter) public class Pola669Filter: ResponseFilter {
    required public init() {
        super.init(responseName: "Pola669")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension Pola669Filter: EffectFilter {
    public var displayName: String {
        return "669"
    }

    public var filterType: FilterType {
        return .Pola669
    }
}
