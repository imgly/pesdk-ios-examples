//
//  MainEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias EditorCompletionBlock = (IMGLYEditorResult, UIImage?) -> Void

private let ButtonCollectionViewCellReuseIdentifier = "ButtonCollectionViewCell"
private let ButtonCollectionViewCellSize = CGSize(width: 70, height: 90)

@objc(IMGLYMainEditorViewController) public class MainEditorViewController: EditorViewController {
    
    // MARK: - Properties
    
    public lazy var actionButtons: [ActionButton] = {
        let bundle = NSBundle(forClass: MainEditorViewController.self)
        var handlers = [ActionButton]()
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.magic", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_magic", inBundle: bundle, compatibleWithTraitCollection: nil),
                selectedImage: UIImage(named: "icon_option_magic_active", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Magic) },
                showSelection: { [unowned self] in return self.fixedFilterStack.enhancementFilter!.enabled }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.filter", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_filters", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Filter) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.stickers", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_sticker", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Stickers) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.orientation", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_orientation", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Orientation) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.focus", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_focus", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Focus) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.crop", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_crop", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Crop) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.brightness", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_brightness", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Brightness) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.contrast", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_contrast", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Contrast) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.saturation", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_saturation", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Saturation) }))
        
        handlers.append(
            ActionButton(
                title: NSLocalizedString("main-editor.button.text", tableName: nil, bundle: bundle, value: "", comment: ""),
                image: UIImage(named: "icon_option_text", inBundle: bundle, compatibleWithTraitCollection: nil),
                handler: { [unowned self] in self.subEditorButtonPressed(.Text) }))
        
        return handlers
        }()
    
    public var completionBlock: EditorCompletionBlock?
    public var initialFilterType = IMGLYFilterType.None
    private let fixedFilterStack = IMGLYFixedFilterStack()
    
    private let maxLowResolutionSideLength = CGFloat(800)
    public var highResolutionImage: UIImage? {
        didSet {
            generateLowResolutionImage()
        }
    }
    private var lowResolutionImage: UIImage?
    private var lowResolutionImageBackup: UIImage?
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: EditorViewController.self)
        navigationItem.title = NSLocalizedString("main-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelTapped:")
        
        fixedFilterStack.effectFilter = IMGLYInstanceFactory.sharedInstance.effectFilterWithType(initialFilterType) as? IMGLYResponseFilter
        updatePreviewImage()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = ButtonCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCellReuseIdentifier)
        
        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: nil, metrics: nil, views: views))
    }
    
    // MARK: - Helpers
    
    func subEditorButtonPressed(buttonType: IMGLYMainMenuButtonType) {
        if (buttonType == IMGLYMainMenuButtonType.Magic) {
            if !updating {
                fixedFilterStack.enhancementFilter!.enabled = !fixedFilterStack.enhancementFilter!.enabled
                updatePreviewImage()
            }
        } else {
            if let viewController = IMGLYInstanceFactory.sharedInstance.viewControllerForButtonType(buttonType) {
                viewController.fixedFilterStack = fixedFilterStack
                viewController.previewImage = lowResolutionImageBackup
                //                viewController!.completionHandler = subEditorCompletionBlock
                
                //                if let viewController = viewController as? UIViewController {
                //                    viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                //                }
                
                showViewController(viewController as! UIViewController, sender: self)
            }
        }
    }
    
    func updatePreviewImage() {
        if let lowResolutionImage = lowResolutionImage {            
            updating = true
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image = processedImage
                    self.updating = false
                }
            }
        }
    }
    
    func generateLowResolutionImage() {
        if let highResolutionImage = highResolutionImage {
            if highResolutionImage.size.width > maxLowResolutionSideLength || highResolutionImage.size.height > maxLowResolutionSideLength  {
                let scale: CGFloat
                
                if(highResolutionImage.size.width > highResolutionImage.size.height) {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.width
                } else {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.height
                }
                
                var newWidth  = CGFloat(roundf(Float(highResolutionImage.size.width) * Float(scale)))
                var newHeight = CGFloat(roundf(Float(highResolutionImage.size.height) * Float(scale)))
                lowResolutionImage = highResolutionImage.imageResizedToSize(CGSize(width: newWidth, height: newHeight), withInterpolationQuality: kCGInterpolationDefault)
                
                if let lowResolutionImage = self.lowResolutionImage {
                    lowResolutionImageBackup = UIImage(CGImage: lowResolutionImage.CGImage)
                }
            } else {
                lowResolutionImage = UIImage(CGImage: highResolutionImage.CGImage)
                lowResolutionImageBackup = UIImage(CGImage: highResolutionImage.CGImage)
            }
        }
    }
    
    // MARK: - EditorViewController
    
    override public func tappedDone(sender: UIBarButtonItem?) {
        highResolutionImage = highResolutionImage?.imageRotatedToMatchOrientation
        var filteredHighResolutionImage: UIImage?
        
        if let highResolutionImage = self.highResolutionImage {
            filteredHighResolutionImage = IMGLYPhotoProcessor.processWithUIImage(highResolutionImage, filters: fixedFilterStack.activeFilters)
        }
        
        dismissViewControllerAnimated(true, completion: {
            self.completionBlock?(.Done, filteredHighResolutionImage)
        })
    }
    
    @objc private func cancelTapped(sender: UIBarButtonItem?) {
        dismissViewControllerAnimated(true, completion: {
            self.completionBlock?(.Cancel, nil)
        })
    }
}

extension MainEditorViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(actionButtons)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ButtonCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        if let buttonCell = cell as? ButtonCollectionViewCell {
            let bundle = NSBundle(forClass: MainEditorViewController.self)
            let actionButton = actionButtons[indexPath.item]
            
            if let selectedImage = actionButton.selectedImage, let showSelectionBlock = actionButton.showSelection where showSelectionBlock() {
                buttonCell.imageView.image = selectedImage
            } else {
                buttonCell.imageView.image = actionButton.image
            }
            
            buttonCell.textLabel.text = actionButton.title
        }
        
        return cell
    }
}

extension MainEditorViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let actionButton = actionButtons[indexPath.item]
        actionButton.handler()
        
        if actionButton.selectedImage != nil && actionButton.showSelection != nil {
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
}
