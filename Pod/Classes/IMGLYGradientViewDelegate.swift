//
// Created by Carsten Przyluczky on 01/03/15.
// Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public protocol IMGLYGradientViewDelegate: class {
    func userInteractionStarted()
    func userInteractionEnded()
    func controlPointChanged()
}
