//
//  IMGLYSummerFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYSummerFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Summer")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYSummerFilter: EffectFilterType {
    public var displayName: String {
        return "Summer"
    }

    public var filterType: IMGLYFilterType {
        return .Summer
    }
}
