//
//  Colorfulilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYColorfulFilter) public class ColorfulFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Colorful")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ColorfulFilter: EffectFilter {
    public var displayName: String {
        return "Colorful"
    }

    public var filterType: FilterType {
        return .Colorful
    }
}
