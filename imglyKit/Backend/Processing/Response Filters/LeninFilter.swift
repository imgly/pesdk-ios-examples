//
//  IMGLYLeninFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYLeninFilter: IMGLYResponseFilter {
    required public init() {
        super.init(responseName: "Lenin")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension IMGLYLeninFilter: EffectFilterType {
    public var displayName: String {
        return "Lenin"
    }

    public var filterType: IMGLYFilterType {
        return .Lenin
    }
}
