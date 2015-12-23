//
//  IMGLYLomo100Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYLomo100Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Lomo100")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYLomo100Filter: EffectFilterType {
    public var displayName: String {
        return "Lomo 100"
    }

    public var filterType: IMGLYFilterType {
        return .Lomo100
    }
}
