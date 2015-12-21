//
//  IMGLYLomo100Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYLomo100Filter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Lomo100")
        self.imgly_displayName = "Lomo 100"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType: IMGLYFilterType {
        return .Lomo100
    }
}
