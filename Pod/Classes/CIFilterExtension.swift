//
//  CIFilterExtension.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 22/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit
import ObjectiveC

private var displayNameAssociationKey: UInt8 = 0

public extension CIFilter {
    public func imageInputAttributeKeys() -> [String] {
        // cache the enumerated image input attributes
        var associationKey = "_storedImageInputAttributeKeys"
        var attributes: AnyObject! = objc_getAssociatedObject(self, associationKey);
        if (attributes != nil) {
            attributes = []
            for key in self.inputKeys()  {
                var attr:[NSObject : AnyObject] = self.attributes()
                var attrDict: AnyObject? = attr[key as! NSObject]
                
                if attrDict!.objectForKey(kCIAttributeType)!.isEqualToString(kCIAttributeTypeImage) {
                    attributes.appendString(key as! String)
                }
            }
            objc_setAssociatedObject(self, associationKey, attributes, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        return attributes as! [String]
    }
    
    public func imageInputCount() -> Int {
        return self.imageInputAttributeKeys().count;
    }
    
    public func isUsableFilter() -> Bool {
        return self.name() != "CIColorCube"
    }
    
    public var displayName: String? {
        get {
            return objc_getAssociatedObject(self, &displayNameAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &displayNameAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
}