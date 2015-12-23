//
//  Configuration.swift
//  imglyKit
//
//  Created by Malte Baumann on 25/11/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

public enum ConfigurationError: ErrorType {
    case ReplacingClassNotASubclass
}

/// This closure allows the configuration of the given barbutton item.
public typealias BarButtonItemConfigurationClosure = (UIBarButtonItem) -> ()

/// This closure allows the configuration of the given button.
public typealias ButtonConfigurationClosure = (UIButton) -> ()

/// This closure allows the configuration of the given label.
public typealias LabelConfigurationClosure = (UILabel) -> ()

/// This closure allows the configuration of the given slider.
public typealias SliderConfigurationClosure = (UISlider) -> ()

/// This closure allows the configuration of the given text field.
public typealias TextFieldConfigurationClosure = (UITextField) -> ()

/**
 An Configuration defines behaviour and look of all view controllers
 provided by the imglyKit. It uses the builder pattern to create an
 immutable object via a closure. To configure the different editors and
 viewControllers contained in the SDK, edit their options in the corresponding
 `configure*ViewController` method of the `ConfigurationBuilder`.
*/
@objc public class Configuration: NSObject {

    // MARK: Properties

    /// Defaults to black.
    public let backgroundColor: UIColor

    /// Camera View Controller
    public let cameraViewControllerOptions: CameraViewControllerOptions

    // Editor View Controller options
    public let mainEditorViewControllerOptions: MainEditorViewControllerOptions
    public let filterEditorViewControllerOptions: FilterEditorViewControllerOptions
    public let stickersEditorViewControllerOptions: StickersEditorViewControllerOptions
    public let orientationEditorViewControllerOptions: OrientationEditorViewControllerOptions
    public let focusEditorViewControllerOptions: FocusEditorViewControllerOptions
    public let cropEditorViewControllerOptions: CropEditorViewControllerOptions
    public let brightnessEditorViewControllerOptions: SliderEditorViewControllerOptions
    public let contrastEditorViewControllerOptions: SliderEditorViewControllerOptions
    public let saturationEditorViewControllerOptions: SliderEditorViewControllerOptions
    public let textEditorViewControllerOptions: TextEditorViewControllerOptions

    //  MARK: Initialization

    override convenience init() {
        self.init(builder: { _ in })
    }

    public init(builder: (ConfigurationBuilder -> Void)) {
        let builderForClosure = ConfigurationBuilder()
        builder(builderForClosure)
        self.backgroundColor = builderForClosure.backgroundColor
        self.cameraViewControllerOptions = builderForClosure.cameraViewControllerOptions
        self.mainEditorViewControllerOptions = builderForClosure.mainEditorViewControllerOptions
        self.filterEditorViewControllerOptions = builderForClosure.filterEditorViewControllerOptions
        self.stickersEditorViewControllerOptions = builderForClosure.stickersEditorViewControllerOptions
        self.orientationEditorViewControllerOptions = builderForClosure.orientationEditorViewControllerOptions
        self.focusEditorViewControllerOptions = builderForClosure.focusEditorViewControllerOptions
        self.cropEditorViewControllerOptions = builderForClosure.cropEditorViewControllerOptions
        self.brightnessEditorViewControllerOptions = builderForClosure.brightnessEditorViewControllerOptions
        self.contrastEditorViewControllerOptions = builderForClosure.contrastEditorViewControllerOptions
        self.saturationEditorViewControllerOptions = builderForClosure.saturationEditorViewControllerOptions
        self.textEditorViewControllerOptions = builderForClosure.textEditorViewControllerOptions
        self.classReplacingMap = builderForClosure.classReplacingMap
        super.init()
    }

    /// Used internally to fetch a replacement class for framework classes.
    func getClassForReplacedClass(replacedClass: NSObject.Type) -> NSObject.Type {
        guard let replacingClassName = classReplacingMap[String(replacedClass)] else {
            return replacedClass
        }

        // swiftlint:disable force_cast
        return NSClassFromString(replacingClassName) as! NSObject.Type
        // swiftlint:enable force_cast
    }

    private let classReplacingMap: [String: String]
}

/**
 The configuration builder object offers all properties of `Configuration` in
 a mutable version, in order to build an immutable `Configuration` object. To
 further configure the different viewcontrollers, use the `configureXYZViewController`
 methods to edit the given options.
*/
@objc public class ConfigurationBuilder: NSObject {
    public var backgroundColor: UIColor = UIColor.blackColor()
    private var cameraViewControllerOptions: CameraViewControllerOptions = CameraViewControllerOptions()
    private var mainEditorViewControllerOptions: MainEditorViewControllerOptions = MainEditorViewControllerOptions()
    private var filterEditorViewControllerOptions: FilterEditorViewControllerOptions = FilterEditorViewControllerOptions()
    private var stickersEditorViewControllerOptions: StickersEditorViewControllerOptions = StickersEditorViewControllerOptions()
    private var orientationEditorViewControllerOptions: OrientationEditorViewControllerOptions = OrientationEditorViewControllerOptions()
    private var focusEditorViewControllerOptions: FocusEditorViewControllerOptions = FocusEditorViewControllerOptions()
    private var cropEditorViewControllerOptions: CropEditorViewControllerOptions = CropEditorViewControllerOptions()
    private var brightnessEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var contrastEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var saturationEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var textEditorViewControllerOptions: TextEditorViewControllerOptions = TextEditorViewControllerOptions()

    public func configureCameraViewController(builder: (CameraViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = CameraViewControllerOptionsBuilder()
        builder(builderForClosure)
        cameraViewControllerOptions = CameraViewControllerOptions(builder: builderForClosure)
    }

    public func configureMainEditorViewController(builder: (MainEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = MainEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        mainEditorViewControllerOptions = MainEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureFilterEditorViewController(builder: (FilterEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = FilterEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        filterEditorViewControllerOptions = FilterEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureStickersEditorViewController(builder: (StickersEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = StickersEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        stickersEditorViewControllerOptions = StickersEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureOrientationEditorViewController(builder: (OrientationEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = OrientationEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        orientationEditorViewControllerOptions = OrientationEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureFocusEditorViewController(builder: (FocusEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = FocusEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        focusEditorViewControllerOptions = FocusEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureCropEditorViewController(builder: (CropEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = CropEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        cropEditorViewControllerOptions = CropEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureBrightnessEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        brightnessEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureSaturationEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        saturationEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureContrastEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        contrastEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    public func configureTextEditorViewController(builder: (TextEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = TextEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        textEditorViewControllerOptions = TextEditorViewControllerOptions(builder: builderForClosure)
    }

    // MARK: Class replacement

    /**
    Use this to use a specific subclass instead of the default imglyKit **view controller** classes. This works
    across all the whole framework and allows you to subclass all usages of a class. As of now, only **view
    controller** can be replaced!

    - parameter builtinClass:   The built in class, that should be replaced.
    - parameter replacingClass: The class that replaces the builtin class.
    - parameter namespace:      The namespace of the replacing class (e.g. Your_App). Usually
                                the module name of your app. Can be found under 'Product Module Name'
                                in your app targets build settings.

    - throws: An exception if the replacing class is not a subclass of the replaced class.
    */
    public func replaceClass(builtinClass: NSObject.Type, replacingClass: NSObject.Type, namespace: String) throws {
        if !replacingClass.isSubclassOfClass(builtinClass) {
            throw ConfigurationError.ReplacingClassNotASubclass
        }

        let builtinClassName = String(builtinClass)
        let replacingClassName = "\(namespace).\(String(replacingClass))"

        classReplacingMap[builtinClassName] = replacingClassName
        print("imglyKit: Using \(replacingClassName) instead of \(builtinClassName)")
    }

    // MARK: Private properties

    var classReplacingMap: [String: String] = [:]
}
