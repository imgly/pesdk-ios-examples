//
//  BorderEditorViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit

@objc public enum BorderAction: Int {
    case Delete
    case BringToFront
    case FlipHorizontally
    case FlipVertically
}

let kBorderCollectionViewCellSize = CGSize(width: 90, height: 90)

// swiftlint:disable variable_name
let kBorderCollectionViewCellReuseIdentifier = "BorderCollectionViewCell"
// swiftlint:enable variable_name

@objc(IMGLYBorderEditorViewController) public class BorderEditorViewController: SubEditorViewController {

    // MARK: - Properties

    public var bordersDataSource = BordersDataSource()
    public private(set) lazy var bordersClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    private var draggedView: UIImageView?
    private var tempBorderCopy = [Filter]()
    private var overlayConverter: OverlayConverter?
    private var borderCount = 0
    private var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var imageRatio: Float = 1.0

    // MARK: - EditorViewController

    public override var options: BorderEditorViewControllerOptions {
        return self.configuration.borderEditorViewControllerOptions
    }

    override var enableZoomingInPreviewImage: Bool {
        return false
    }

    // MARK: - SubEditorViewController

    public override func tappedDone(sender: UIBarButtonItem?) {
        let addedStickers = self.overlayConverter?.addSpriteFiltersFromUIElements(bordersClipView, previewSize: previewImageView.visibleImageFrame.size, previewImage: previewImageView.image!)
        if addedStickers != nil {
            updatePreviewImageWithCompletion {
                self.bordersClipView.removeFromSuperview()
                super.tappedDone(sender)
            }
        } else {
            super.tappedDone(sender)
        }
    }

    // MARK: - UIViewController

    /**
    :nodoc:
    */
    override public func viewDidLoad() {
        super.viewDidLoad()

        configureStickersCollectionView()
        configureStickersClipView()
        configureOverlayConverter()
        backupBorders()
        fixedFilterStack.spriteFilters.removeAll()
        invokeCollectionViewDataFetch()
    }

    private func invokeCollectionViewDataFetch() {
        options.bordersDataSource.borderCount({ count, error in
            self.borderCount = count
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
            if let error = error {
                print(error.description)
            }
        })
    }

    /**
     :nodoc:
     */
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rerenderPreviewWithoutStickers()
        options.didEnterToolClosure?()
    }

    /**
     :nodoc:
     */
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        options.willLeaveToolClosure?()
    }

    /**
     :nodoc:
     */
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bordersClipView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
    }

    // MARK: - Configuration

    private func configureOverlayConverter() {
        self.overlayConverter = OverlayConverter(fixedFilterStack: self.fixedFilterStack)
    }

    private func configureStickersCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = kStickersCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = currentBackgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(StickerCollectionViewCell.self, forCellWithReuseIdentifier: kStickersCollectionViewCellReuseIdentifier)

        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: [], metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }

    private func configureStickersClipView() {
        view.addSubview(bordersClipView)
    }

    // MARK: - border object restore

    private func rerenderPreviewWithoutStickers() {
        updatePreviewImageWithCompletion { () -> (Void) in
            self.overlayConverter?.addUIElementsFromSpriteFilters(self.tempBorderCopy, containerView: self.bordersClipView, previewSize: self.previewImageView.visibleImageFrame.size)

            // Recreate accessibility functions
            for view in self.bordersClipView.subviews {
                if let imageView = view as? StickerImageView {
                    // Check datasource for sticker to get label
                    //var border: Border?
                    /*for i in 0 ..< self.options.bordersDataSource.borderCount {
                        self.options.bordersDataSource.borderAtIndex(i, completionBlock: { candidate in
                            if let candidate = candidate {
                                if candidate.image == imageView.image {
                                    border = candidate
                                }
                            }
                        })
                    }*/

                    //if let label = border?.label {
                    //    imageView.accessibilityLabel = Localize(label)
                    //}

                    imageView.decrementHandler = { [unowned imageView] in
                        // Decrease by 10 %
                        imageView.transform = CGAffineTransformScale(imageView.transform, 0.9, 0.9)
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                    }

                    imageView.incrementHandler = { [unowned imageView] in
                        // Increase by 10 %
                        imageView.transform = CGAffineTransformScale(imageView.transform, 1.1, 1.1)
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                    }

                    imageView.rotateLeftHandler = { [unowned imageView] in
                        // Rotate by 10 degrees to the left
                        imageView.transform = CGAffineTransformRotate(imageView.transform, -10 * CGFloat(M_PI) / 180)
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                    }

                    imageView.rotateRightHandler = { [unowned imageView] in
                        // Rotate by 10 degrees to the right
                        imageView.transform = CGAffineTransformRotate(imageView.transform, 10 * CGFloat(M_PI) / 180)
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                    }
                }
            }
        }
    }

    private func backupBorders() {
        tempBorderCopy = fixedFilterStack.spriteFilters
    }

    // MARK: - Helpers

    private func hitImageView(point: CGPoint) -> UIImageView? {
        var result: UIImageView? = nil
        for imageView in bordersClipView.subviews where imageView is UIImageView {
            if imageView.frame.contains(point) {
                result = imageView as? UIImageView
            }
        }
        return result
    }
}

extension BorderEditorViewController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(borderCount)
        return borderCount
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kStickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! StickerCollectionViewCell
        // swiftlint:enable force_cast

        options.bordersDataSource.borderAtIndex(indexPath.item, completionBlock: { border, error in
            if let border = border {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath)
                    if let updateCell = updateCell as? StickerCollectionViewCell {
                        updateCell.imageView.image = border.thumbnail ?? border.imageForRatio(self.imageRatio)
                        if let label = border.label {
                            updateCell.accessibilityLabel = Localize(label)
                        }
                    }
                })
            } else {
                print(error)
            }
        })
        return cell
    }
}

extension BorderEditorViewController: UICollectionViewDelegate {
    // add selected sticker
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        options.bordersDataSource.borderAtIndex(indexPath.item, completionBlock: { border, error in
            if let border = border {
                let imageView = StickerImageView(image: border.imageForRatio(self.imageRatio))
                if let size = self.overlayConverter?.initialSizeForStickerImage(border.imageForRatio(self.imageRatio)!, containerView: self.bordersClipView) {
                    imageView.frame.size = size
                }

                imageView.center = CGPoint(x: self.bordersClipView.bounds.midX, y: self.bordersClipView.bounds.midY)

                if let label = border.label {
                    imageView.accessibilityLabel = Localize(label)
                    self.options.addedBorderClosure?(label)
                }

                imageView.decrementHandler = { [unowned imageView] in
                    // Decrease by 10 %
                    imageView.transform = CGAffineTransformScale(imageView.transform, 0.9, 0.9)
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                }

                imageView.incrementHandler = { [unowned imageView] in
                    // Increase by 10 %
                    imageView.transform = CGAffineTransformScale(imageView.transform, 1.1, 1.1)
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                }

                imageView.rotateLeftHandler = { [unowned imageView] in
                    // Rotate by 10 degrees to the left
                    imageView.transform = CGAffineTransformRotate(imageView.transform, -10 * CGFloat(M_PI) / 180)
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                }

                imageView.rotateRightHandler = { [unowned imageView] in
                    // Rotate by 10 degrees to the right
                    imageView.transform = CGAffineTransformRotate(imageView.transform, 10 * CGFloat(M_PI) / 180)
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
                }

                let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
                let scaleX = 1.0 / cropRect.width
                let scaleY = 1.0 / cropRect.height
                let scale = min(scaleX, scaleY)
                imageView.frame.size.width *= scale
                imageView.frame.size.height *= scale

                self.bordersClipView.addSubview(imageView)
                imageView.transform = CGAffineTransformMakeScale(0, 0)

                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                    imageView.transform = CGAffineTransformMakeScale(1.0 / scale, 1.0 / scale)
                    }) { _ in
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, imageView)
                }
            }
        })
    }
}

extension BorderEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        return false
    }
}
