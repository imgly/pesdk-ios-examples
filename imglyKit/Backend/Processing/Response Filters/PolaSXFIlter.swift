//
//  PolaSXFIlter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYPolaSXFilter) public class PolaSXFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "PolaSX")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PolaSXFilter: EffectFilter {
    public var displayName: String {
        return "SX"
    }

    public var filterType: FilterType {
        return .PolaSX
    }
}
