//
//  IMGLYMainEditorActionsDataSource.swift
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
 are defined in the IMGLYMainEditorActionOption option set.
 */
@objc public protocol IMGLYMainEditorActionsDataSourceProtocol {
    
    /// The total count of all actions.
    var actionCount: Int { get }
    
    /**
     - parameter index: The index of the requested action.
     - returns: An `IMGLYMainEditorAction`
     */
    func actionAtIndex(index: Int) -> IMGLYMainEditorAction
}

/**
 A default implementation of the `IMGLYMainEditorActionsDataSourceProtocol`.
 The default initializer creates an object, that provides all available editors.
 By using the `init(availableActionTypes:)` you can specify the available editors.
*/
@objc public class IMGLYMainEditorActionsDataSource : NSObject, IMGLYMainEditorActionsDataSourceProtocol {
    
    private var items: [IMGLYMainEditorAction] = []
    
    // MARK: Init
    
    /**
    Creates a default datasource offering all available editors.
    */
    public override init() {
        super.init()
        items = self.itemsForAvailableActions([ .Magic, .Filter, .Stickers, .Orientation, .Focus, .Crop, .Brightness, .Contrast, .Saturation, .Text ])
    }
    
    /**
     Creates a default datasource offering the given editor actions. The actions
     are presented in the given order. Duplicates are not removed.
     - Parameter availableActionTypes: An array of supported `IMGLYMainEditorActionType`s.
    */
    public convenience init(availableActionTypes: [IMGLYMainEditorActionType]) {
        self.init()
        items = self.itemsForAvailableActions(availableActionTypes)
    }
    
    /**
     This initializer should only be called from Objective-C. It
     creates a default datasource offering the given actionTypes.
     - Parameter availableActionTypesAsNSNumbers: An NSOrderedSet
     containing NSNumbers that wrap the raw value of the corresponding
     IMGLYMainEditorActionType
     */
    public convenience init(availableActionTypesAsNSNumbers: NSOrderedSet) {
        self.init()
        
    }
    
    // MARK: IMGLYMainEditorActionsDataSource
    
    public var actionCount: Int {
        return items.count
    }

    public func actionAtIndex(index: Int) -> IMGLYMainEditorAction {
        return items[index]
    }
    
    // MARK: Default EditorActions
    
    private func itemsForAvailableActions(types:[IMGLYMainEditorActionType]) -> [IMGLYMainEditorAction] {
        let bundle = NSBundle(forClass: IMGLYMainEditorViewController.self)
        var actions: [IMGLYMainEditorAction] = []
        for actionType in types {
            switch actionType {
            case .Magic:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.magic", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_magic", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    selectedImage: UIImage(named: "icon_option_magic_active", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Magic))
            case .Filter:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.filter", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_filters", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Filter))
            case .Stickers:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.stickers", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_sticker", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Stickers))
            case .Orientation:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.orientation", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_orientation", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Orientation))
            case .Focus:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.focus", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_focus", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Focus))
            case .Crop:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.crop", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_crop", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Crop))
            case .Brightness:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.brightness", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_brightness", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Brightness))
            case .Contrast:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.contrast", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_contrast", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Contrast))
            case .Saturation:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.saturation", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_saturation", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Saturation))
            case .Text:
                actions.append(IMGLYMainEditorAction(title: NSLocalizedString("main-editor.button.text", tableName: nil, bundle: bundle, value: "", comment: ""),
                    image: UIImage(named: "icon_option_text", inBundle: bundle, compatibleWithTraitCollection: nil)!.imageWithRenderingMode(.AlwaysTemplate),
                    editorType: .Text))
            }
        }
        
        return actions
    }
}
