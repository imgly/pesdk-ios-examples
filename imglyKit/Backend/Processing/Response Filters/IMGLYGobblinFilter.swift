//
//  IMGLYGobblinFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYGoblinFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Goblin")
        self.imgly_displayName = "Goblin"
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Goblin
        }
    }
}
