//
//  NSErrorExtension.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 15/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

let kIMGLYErrorDomain = "IMGLYErrorDomain"

extension NSError {
    convenience init(info: String) {
        self.init(domain: kIMGLYErrorDomain, code: 0, userInfo: [
            NSLocalizedDescriptionKey: info ])
    }
}
