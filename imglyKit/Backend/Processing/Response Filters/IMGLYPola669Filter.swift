//
//  IMGLYPola669Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYPola669Filter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Pola669")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYPola669Filter: EffectFilterType {
    public var displayName: String {
        return "669"
    }

    public var filterType: IMGLYFilterType {
        return .Pola669
    }
}
