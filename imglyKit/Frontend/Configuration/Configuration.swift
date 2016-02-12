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

/// This closure will be called when a tool has been entered.
public typealias DidEnterToolClosure = () -> ()

/// The closure will be called when a tool is about to be left.
public typealias WillLeaveToolClosure = () -> ()

/**
 An Configuration defines behaviour and look of all view controllers
 provided by the imglyKit. It uses the builder pattern to create an
 immutable object via a closure. To configure the different editors and
 viewControllers contained in the SDK, edit their options in the corresponding
 `configure*ViewController` method of the `ConfigurationBuilder`.
*/
@objc(IMGLYConfiguration) public class Configuration: NSObject {

    // MARK: Properties

    /// The background color. Defaults to black.
    public let backgroundColor: UIColor
    /// Options for the `CameraViewController`.
    public let cameraViewControllerOptions: CameraViewControllerOptions
    /// Options for the `MainEditorViewController`.
    public let mainEditorViewControllerOptions: MainEditorViewControllerOptions
    /// Options for the `FilterEditorViewController`.
    public let filterEditorViewControllerOptions: FilterEditorViewControllerOptions
    /// Options for the `StickersEditorViewController`.
    public let stickersEditorViewControllerOptions: StickersEditorViewControllerOptions
    /// Options for the `BorderEditorViewController`.
    public let borderEditorViewControllerOptions: BorderEditorViewControllerOptions
    /// Options for the `OrientationEditorViewController`.
    public let orientationEditorViewControllerOptions: OrientationEditorViewControllerOptions
    /// Options for the `FocusEditorViewController`.
    public let focusEditorViewControllerOptions: FocusEditorViewControllerOptions
    /// Options for the `CropEditorViewController`.
    public let cropEditorViewControllerOptions: CropEditorViewControllerOptions
    /// Options for the `BrightnessEditorViewController`.
    public let brightnessEditorViewControllerOptions: SliderEditorViewControllerOptions
    /// Options for the `ContrastEditorViewController`.
    public let contrastEditorViewControllerOptions: SliderEditorViewControllerOptions
    /// Options for the `SaturationEditorViewController`.
    public let saturationEditorViewControllerOptions: SliderEditorViewControllerOptions
    /// Options for the `TextEditorViewController`.
    public let textEditorViewControllerOptions: TextEditorViewControllerOptions

    //  MARK: Initialization

    /**
    Returns a newly allocated instance of a `Configuration` using the default builder.

    - returns: An instance of a `Configuration`.
    */
    override convenience init() {
        self.init(builder: { _ in })
    }

    /**
     Returns a newly allocated instance of a `Configuration` using the given builder.

     - parameter builder: A `ConfigurationBuilder` instance.

     - returns: An instance of a `Configuration`.
     */
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
        self.borderEditorViewControllerOptions = builderForClosure.borderEditorViewControllerOptions
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
@objc(IMGLYConfigurationBuilder) public class ConfigurationBuilder: NSObject {
    /// The background color. Defaults to black.
    public var backgroundColor: UIColor = UIColor.blackColor()
    private var cameraViewControllerOptions: CameraViewControllerOptions = CameraViewControllerOptions()
    private var mainEditorViewControllerOptions: MainEditorViewControllerOptions = MainEditorViewControllerOptions()
    private var filterEditorViewControllerOptions: FilterEditorViewControllerOptions = FilterEditorViewControllerOptions()
    private var stickersEditorViewControllerOptions: StickersEditorViewControllerOptions = StickersEditorViewControllerOptions()
    private var borderEditorViewControllerOptions: BorderEditorViewControllerOptions = BorderEditorViewControllerOptions()
    private var orientationEditorViewControllerOptions: OrientationEditorViewControllerOptions = OrientationEditorViewControllerOptions()
    private var focusEditorViewControllerOptions: FocusEditorViewControllerOptions = FocusEditorViewControllerOptions()
    private var cropEditorViewControllerOptions: CropEditorViewControllerOptions = CropEditorViewControllerOptions()
    private var brightnessEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var contrastEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var saturationEditorViewControllerOptions: SliderEditorViewControllerOptions = SliderEditorViewControllerOptions()
    private var textEditorViewControllerOptions: TextEditorViewControllerOptions = TextEditorViewControllerOptions()

    /// Options for the `CameraViewController`.
    public func configureCameraViewController(builder: (CameraViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = CameraViewControllerOptionsBuilder()
        builder(builderForClosure)
        cameraViewControllerOptions = CameraViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `MainEditorViewController`.
    public func configureMainEditorViewController(builder: (MainEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = MainEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        mainEditorViewControllerOptions = MainEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `FilterEditorViewController`.
    public func configureFilterEditorViewController(builder: (FilterEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = FilterEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        filterEditorViewControllerOptions = FilterEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `StickersEditorViewController`.
    public func configureStickersEditorViewController(builder: (StickersEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = StickersEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        stickersEditorViewControllerOptions = StickersEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `OrientationEditorViewController`.
    public func configureOrientationEditorViewController(builder: (OrientationEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = OrientationEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        orientationEditorViewControllerOptions = OrientationEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `FocusEditorViewController`.
    public func configureFocusEditorViewController(builder: (FocusEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = FocusEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        focusEditorViewControllerOptions = FocusEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `CropEditorViewController`.
    public func configureCropEditorViewController(builder: (CropEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = CropEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        cropEditorViewControllerOptions = CropEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `BrightnessEditorViewController`.
    public func configureBrightnessEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        brightnessEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `SaturationEditorViewController`.
    public func configureSaturationEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        saturationEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `ContrastEditorViewController`.
    public func configureContrastEditorViewController(builder: (SliderEditorViewControllerOptionsBuilder -> Void)) {
        let builderForClosure = SliderEditorViewControllerOptionsBuilder()
        builder(builderForClosure)
        contrastEditorViewControllerOptions = SliderEditorViewControllerOptions(builder: builderForClosure)
    }

    /// Options for the `TextEditorViewController`.
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
