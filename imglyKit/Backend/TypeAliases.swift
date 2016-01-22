//
//  TypeAliases.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 08/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    public typealias Color = UIColor
    public typealias Font = UIFont
    public typealias Image = UIImage
#else
    import Cocoa
    public typealias Color = NSColor
    public typealias Font = NSFont
    public typealias Image = NSImage
#endif
