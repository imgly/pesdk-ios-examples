//
//  ColorPhotoFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 24/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

@objc(IMGLYEveningFilter) public class EveningFilter: ResponseFilter {
    required public init() {
        super.init(responseName: "Evening")
    }

    /**
     Returns an object initialized from data in a given unarchiver.

     - parameter aDecoder: An unarchiver object.

     - returns: `self`, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension EveningFilter: EffectFilter {
    public var displayName: String {
        return "Evening"
    }

    public var filterType: FilterType {
        return .Evening
    }
}
