//
//  IMGLYX400Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYX400Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "X400")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYX400Filter: EffectFilterType {
    public var displayName: String {
        return "X400"
    }

    public var filterType: IMGLYFilterType {
        return .X400
    }
}
