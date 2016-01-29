//
//  MainEditorActionsDataSource.swift
//  imglyKit
//
//  Created by Malte Baumann on 02/12/15.
//  Copyright © 2015 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 A MainEditorActionsDatasource describes a datasource for the available
 editor buttons in the bottom drawer of the main editor. The available types
 are defined in the MainEditorActionOption option set.
 */
@objc(IMGLYMainEditorActionsDataSourceProtocol) public protocol MainEditorActionsDataSourceProtocol {

    /// The total count of all actions.
    var actionCount: Int { get }

    /**
     - parameter index: The index of the requested action.
     - returns: An `MainEditorAction`
     */
    func actionAtIndex(index: Int) -> MainEditorAction
}

/**
 A default implementation of the `MainEditorActionsDataSourceProtocol`.
 The default initializer creates an object, that provides all available editors.
 By using the `init(availableActionTypes:)` you can specify the available editors.
*/
@objc(IMGLYMainEditorActionsDataSource) public class MainEditorActionsDataSource: NSObject, MainEditorActionsDataSourceProtocol {

    private var items: [MainEditorAction] = []

    // MARK: Init

    /**
    Creates a default datasource offering all available editors.
    */
    public override init() {
        super.init()
        items = self.itemsForAvailableActions([ .Magic, .Crop, .Orientation, .Filter, .Brightness, .Contrast, .Saturation, .Text, .Stickers, .Focus ])
    }

    /**
     Creates a default datasource offering the given editor actions. The actions
     are presented in the given order. Duplicates are not removed.
     - Parameter availableActionTypes: An array of supported `MainEditorActionType`s.
    */
    public convenience init(availableActionTypes: [MainEditorActionType]) {
        self.init()
        items = self.itemsForAvailableActions(availableActionTypes)
    }

    /**
     This initializer should only be called from Objective-C. It
     creates a default datasource offering the given actionTypes. Duplicates are not removed.
     - Parameter availableActionTypesAsNSNumbers: An array
     containing NSNumbers that wrap the raw value of the corresponding
     MainEditorActionType
     */
    public convenience init(availableActionTypesAsNSNumbers: [NSNumber]) {
        self.init()
        items = self.itemsForAvailableActions(availableActionTypesAsNSNumbers.flatMap { MainEditorActionType(rawValue: $0.integerValue) })
    }

    // MARK: MainEditorActionsDataSource

    public var actionCount: Int {
        return items.count
    }

    public func actionAtIndex(index: Int) -> MainEditorAction {
        return items[index]
    }

    // MARK: Default EditorActions

    private func itemsForAvailableActions(types: [MainEditorActionType]) -> [MainEditorAction] {
        let bundle = NSBundle(forClass: MainEditorViewController.self)
        var actions: [MainEditorAction] = []
        for actionType in types {
            switch actionType {
            case .Magic:
                actions.append(MainEditorAction(title: Localize("Magic"),
                    image: UIImage(named: "icon_option_magic", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    selectedImage: UIImage(named: "icon_option_magic_active", inBundle: bundle, compatibleWithTraitCollection: nil)!,
                    editorType: .Magic))
            case .Filter:
                actions.append(MainEditorAction(title: Localize("Filter"),
                    image: UIImage(named: "icon_option_filters", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Filter))
            case .Stickers:
                actions.append(MainEditorAction(title: Localize("Stickers"),
                    image: UIImage(named: "icon_option_sticker", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Stickers))
            case .Orientation:
                actions.append(MainEditorAction(title: Localize("Orientation"),
                    image: UIImage(named: "icon_option_orientation", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Orientation))
            case .Focus:
                actions.append(MainEditorAction(title: Localize("Focus"),
                    image: UIImage(named: "icon_option_focus", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Focus))
            case .Crop:
                actions.append(MainEditorAction(title: Localize("Crop"),
                    image: UIImage(named: "icon_option_crop", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Crop))
            case .Brightness:
                actions.append(MainEditorAction(title: Localize("Brightness"),
                    image: UIImage(named: "icon_option_brightness", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Brightness))
            case .Contrast:
                actions.append(MainEditorAction(title: Localize("Contrast"),
                    image: UIImage(named: "icon_option_contrast", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Contrast))
            case .Saturation:
                actions.append(MainEditorAction(title: Localize("Saturation"),
                    image: UIImage(named: "icon_option_saturation", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Saturation))
            case .Text:
                actions.append(MainEditorAction(title: Localize("Text"),
                    image: UIImage(named: "icon_option_text", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Text))
            }
        }

        return actions
    }
}
