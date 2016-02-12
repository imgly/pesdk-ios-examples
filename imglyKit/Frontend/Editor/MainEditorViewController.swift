//
//  MainEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum EditorResult: Int {
    case Done
    case Cancel
}

@objc public enum MainEditorActionType: Int {
    case Magic
    case Filter
    case Stickers
    case Border
    case Orientation
    case Focus
    case Crop
    case Brightness
    case Contrast
    case Saturation
    case Text
}

public typealias EditorCompletionBlock = (EditorResult, UIImage?) -> Void

private let kButtonCollectionViewCellReuseIdentifier = "ButtonCollectionViewCell"
private let kButtonCollectionViewCellSize = CGSize(width: 66, height: 90)

@objc(IMGLYMainEditorViewController) public class MainEditorViewController: EditorViewController {

    // MARK: - Properties

    public var completionBlock: EditorCompletionBlock?
    public var initialFilterType = FilterType.None
    public var initialFilterIntensity = NSNumber(double: 0.75)
    public private(set) var fixedFilterStack = FixedFilterStack()

    private let maxLowResolutionSideLength = CGFloat(1600)
    public var highResolutionImage: UIImage? {
        didSet {
            generateLowResolutionImage()
        }
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelTapped:")
        options.leftBarButtonConfigurationClosure?(navigationItem.leftBarButtonItem!)

        navigationController?.delegate = self

        fixedFilterStack.effectFilter = InstanceFactory.effectFilterWithType(initialFilterType)
        fixedFilterStack.effectFilter.inputIntensity = initialFilterIntensity

        updatePreviewImage {
            let freeCropAllowed = self.configuration.cropEditorViewControllerOptions.allowedCropRatios.contains { $0.ratio == nil }
            if self.options.forceCrop && !freeCropAllowed {
                guard let image = self.previewImageView.image else {
                    return
                }

                let imageAspectRatio = CGFloat(image.size.width / image.size.height)
                var presentCropEditor = true

                for cropRatio in self.configuration.cropEditorViewControllerOptions.allowedCropRatios {
                    if let cropAspectRatio = cropRatio.ratio {
                        if fabs(imageAspectRatio - cropAspectRatio) < 0.00001 {
                            presentCropEditor = false
                        }
                    }
                }

                if presentCropEditor {
                    self.presentSubEditorForActionType(.Crop, withFixedFilterStack: self.fixedFilterStack, configuration: self.configuration, enableBackButton: false)
                }
            }
        }

        configureMenuCollectionView()
    }

    // MARK: - Configuration

    private func configureMenuCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = kButtonCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = currentBackgroundColor
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: kButtonCollectionViewCellReuseIdentifier)

        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }

    // MARK: - Helpers

    private func subEditorButtonPressed(actionType: MainEditorActionType) {
        if actionType == .Magic {
            if !updating {
                fixedFilterStack.enhancementFilter.enabled = !fixedFilterStack.enhancementFilter.enabled
                updatePreviewImage()

            }
        } else {
            presentSubEditorForActionType(actionType, withFixedFilterStack: fixedFilterStack, configuration: configuration)
        }
    }

    private func presentSubEditorForActionType(actionType: MainEditorActionType, withFixedFilterStack fixedFilterStack: FixedFilterStack, configuration: Configuration, enableBackButton: Bool = true) {
        if let viewController = InstanceFactory.viewControllerForEditorActionType(actionType, withFixedFilterStack: fixedFilterStack, configuration: configuration) {
            viewController.lowResolutionImage = lowResolutionImage
            viewController.previewImageView.image = previewImageView.image
            viewController.completionHandler = subEditorDidComplete

            if !enableBackButton {
                viewController.navigationItem.setHidesBackButton(true, animated: false)
            }

            showViewController(viewController, sender: self)
        }
    }

    private func subEditorDidComplete(image: UIImage?, fixedFilterStack: FixedFilterStack) {
        previewImageView.image = image
        self.fixedFilterStack = fixedFilterStack
    }

    private func generateLowResolutionImage() {
        if let highResolutionImage = self.highResolutionImage {
            if highResolutionImage.size.width > maxLowResolutionSideLength || highResolutionImage.size.height > maxLowResolutionSideLength {
                let scale: CGFloat

                if highResolutionImage.size.width > highResolutionImage.size.height {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.width
                } else {
                    scale = maxLowResolutionSideLength / highResolutionImage.size.height
                }

                let newWidth  = CGFloat(roundf(Float(highResolutionImage.size.width) * Float(scale)))
                let newHeight = CGFloat(roundf(Float(highResolutionImage.size.height) * Float(scale)))
                lowResolutionImage = highResolutionImage.imgly_normalizedImageOfSize(CGSize(width: newWidth, height: newHeight))
            } else {
                lowResolutionImage = highResolutionImage.imgly_normalizedImage
            }
        }
    }

    private func updatePreviewImage(completion: (() -> Void)? = nil) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(kPhotoProcessorQueue) {
                let processedImage = PhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)

                dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image = processedImage
                    self.updating = false

                    completion?()
                }
            }
        }
    }

    // MARK: - EditorViewController

    public override var options: MainEditorViewControllerOptions {
        return self.configuration.mainEditorViewControllerOptions
    }

    override public func tappedDone(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            highResolutionImage = highResolutionImage?.imgly_normalizedImage
            var filteredHighResolutionImage: UIImage?

            if let highResolutionImage = self.highResolutionImage {
                sender?.enabled = false
                updating = true
                dispatch_async(kPhotoProcessorQueue) {
                    filteredHighResolutionImage = PhotoProcessor.processWithUIImage(highResolutionImage, filters: self.fixedFilterStack.activeFilters)

                    dispatch_async(dispatch_get_main_queue()) {
                        completionBlock(.Done, filteredHighResolutionImage)
                        self.updating = false
                        sender?.enabled = true
                    }
                }
            } else {
                completionBlock(.Done, filteredHighResolutionImage)
            }
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @objc private func cancelTapped(sender: UIBarButtonItem?) {
        if let completionBlock = completionBlock {
            completionBlock(.Cancel, nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension MainEditorViewController: UICollectionViewDataSource {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.editorActionsDataSource.actionCount
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kButtonCollectionViewCellReuseIdentifier, forIndexPath: indexPath)

        if let buttonCell = cell as? ButtonCollectionViewCell {
            let dataSource = options.editorActionsDataSource
            let action = dataSource.actionAtIndex(indexPath.item)
            buttonCell.textLabel.text = action.title
            buttonCell.imageView.image = action.image
            buttonCell.accessibilityLabel = action.title
        }

        return cell
    }
}

extension MainEditorViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let action = options.editorActionsDataSource.actionAtIndex(indexPath.item)
        subEditorButtonPressed(action.editorType)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let action = options.editorActionsDataSource.actionAtIndex(indexPath.item)
        if action.editorType == .Magic {
            if let buttonCell = cell as? ButtonCollectionViewCell, let selectedImage = action.selectedImage {
                if fixedFilterStack.enhancementFilter.enabled {
                    buttonCell.accessibilityTraits |= UIAccessibilityTraitSelected
                    buttonCell.imageView.image = selectedImage
                    buttonCell.imageView.tintAdjustmentMode = .Dimmed
                } else {
                    buttonCell.accessibilityTraits &= ~UIAccessibilityTraitSelected
                    buttonCell.imageView.image = action.image
                    buttonCell.imageView.tintAdjustmentMode = .Normal
                }
            }
        }
    }
}

extension MainEditorViewController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationAnimationController()
    }
}
