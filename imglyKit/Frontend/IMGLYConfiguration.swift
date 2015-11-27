//
//  IMGLYConfiguration.swift
//  imglyKit
//
//  Created by Malte Baumann on 25/11/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

public enum IMGLYConfigurationError: ErrorType {
    case ReplacingClassNotASubclass
}

/**
An IMGLYConfiguration defines behaviour and look of all view controllers
provided by the imglyKit. It uses the builder pattern to create an
immutable copy via a closure.
*/
@objc public class IMGLYConfiguration : NSObject {
    
    // MARK: Properties
    
    public var mainEditorViewControllerOptions: IMGLYMainEditorViewControllerOptions = IMGLYMainEditorViewControllerOptions()
    
    // MARK: Class replacement
    
    /**
    Use this to use a specific subclass instead of the default imglyKit classes. This works
    across all the whole framework and allows you to subclass all usages of a class.
    
    - Throws: An exception if the replacing class is not a subclass of the replaced class.
    */
    public func replaceClass(builtinClass: NSObject.Type, replacingClass: NSObject.Type, namespace: String) throws {
        
        if (!replacingClass.isSubclassOfClass(builtinClass)) {
            throw IMGLYConfigurationError.ReplacingClassNotASubclass
        }
        
        let builtinClassName = String(builtinClass)
        let replacingClassName = "\(namespace).\(String(replacingClass))"
        
        classReplacingMap[builtinClassName] = replacingClassName
        print("Using \(replacingClassName) instead of \(builtinClassName)")
    }

    func getClassForReplacedClass(replacedClass: NSObject.Type) -> NSObject.Type {
        guard let replacingClassName = classReplacingMap[String(replacedClass)]
            else { return replacedClass }

        return NSClassFromString(replacingClassName) as! NSObject.Type
    }

    // MARK: Private properties
    
    private var classReplacingMap: [String: String] = [:]

}
