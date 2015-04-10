//
//  IMGLYNoneFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

/**
*  A filter that does nothing. It is used within the fixed-filterstack.
*/
public class IMGLYNoneFilter : ResponseFilter {
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(responseName: "None")
        self.displayName = "None"
    }
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            return inputImage!
        }
    }
}