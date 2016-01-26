//
//  StickersEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

let kStickersCollectionViewCellSize = CGSize(width: 90, height: 90)
// swiftlint:disable variable_name_max_length
let kStickersCollectionViewCellReuseIdentifier = "StickersCollectionViewCell"
// swiftlint:enable variable_name_max_length

@objc(IMGLYStickersEditorViewController) public class StickersEditorViewController: SubEditorViewController {

    // MARK: - Properties

    public var stickersDataSource = StickersDataSource()
    public private(set) lazy var stickersClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
        }()

    private var draggedView: UIView?
    private var tempStickerCopy = [Filter]()
    private var overlayConverter: OverlayConverter?

    // MARK: - EditorViewController

    public override var options: StickersEditorViewControllerOptions {
        return self.configuration.stickersEditorViewControllerOptions
    }

    override var enableZoomingInPreviewImage: Bool {
        return false
    }

    // MARK: - SubEditorViewController

    public override func tappedDone(sender: UIBarButtonItem?) {
        let addedStickers = self.overlayConverter?.addSpriteFiltersFromUIElements(stickersClipView, previewSize: previewImageView.visibleImageFrame.size, previewImage: previewImageView.image!)
        if addedStickers != nil {
            updatePreviewImageWithCompletion {
                self.stickersClipView.removeFromSuperview()
                super.tappedDone(sender)
            }
        } else {
            super.tappedDone(sender)
        }
    }

    // MARK: - UIViewController

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureStickersCollectionView()
        configureStickersClipView()
        configureGestureRecognizers()
        configureOverlayConverter()
        backupStickers()
        fixedFilterStack.spriteFilters.removeAll()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        rerenderPreviewWithoutStickers()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stickersClipView.frame = view.convertRect(previewImageView.visibleImageFrame, fromView: previewImageView)
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

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
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
        view.addSubview(stickersClipView)
    }

    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panned:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        stickersClipView.addGestureRecognizer(panGestureRecognizer)

        if options.canModifyStickerSize {
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinched:")
            pinchGestureRecognizer.delegate = self
            stickersClipView.addGestureRecognizer(pinchGestureRecognizer)
        }

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "rotated:")
        rotationGestureRecognizer.delegate = self
        stickersClipView.addGestureRecognizer(rotationGestureRecognizer)
    }

    // MARK: - Gesture Handling

    @objc private func panned(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(stickersClipView)
        let translation = recognizer.translationInView(stickersClipView)

        switch recognizer.state {
        case .Began:
            draggedView = hitImageView(location)
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            }
            recognizer.setTranslation(CGPoint.zero, inView: stickersClipView)
        case .Cancelled, .Ended:
            draggedView = nil
        default:
            break
        }
    }

    @objc private func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: stickersClipView)
            let point2 = recognizer.locationOfTouch(1, inView: stickersClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = hitImageView(midpoint)
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformScale(draggedView.transform, scale, scale)
                }
                recognizer.scale = 1
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    @objc private func rotated(recognizer: UIRotationGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: stickersClipView)
            let point2 = recognizer.locationOfTouch(1, inView: stickersClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let rotation = recognizer.rotation

            switch recognizer.state {
            case .Began:
                if draggedView == nil {
                    draggedView = hitImageView(midpoint)
                }
            case .Changed:
                if let draggedView = draggedView {
                    draggedView.transform = CGAffineTransformRotate(draggedView.transform, rotation)
                }

                recognizer.rotation = 0
            case .Cancelled, .Ended:
                draggedView = nil
            default:
                break
            }
        }
    }

    // MARK:- sticker object restore

    private func rerenderPreviewWithoutStickers() {
        updatePreviewImageWithCompletion { () -> (Void) in
            self.overlayConverter?.addUIElementsFromSpriteFilters(self.tempStickerCopy, containerView:self.stickersClipView, previewSize: self.previewImageView.visibleImageFrame.size)
        }
    }

    private func backupStickers() {
        tempStickerCopy = fixedFilterStack.spriteFilters
    }

    // MARK:- helper

    private func hitImageView(point: CGPoint) -> UIImageView? {
        var result: UIImageView? = nil
        for imageView in stickersClipView.subviews where imageView is UIImageView {
            if imageView.frame.contains(point) {
                result = imageView as? UIImageView
            }
        }
        return result
    }

}

extension StickersEditorViewController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.stickersDataSource.stickerCount
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kStickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! StickerCollectionViewCell
        // swiftlint:enable force_cast

        let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
        cell.imageView.image = sticker.thumbnail ?? sticker.image

        return cell
    }
}

extension StickersEditorViewController: UICollectionViewDelegate {
    // add selected sticker
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
        let imageView = UIImageView(image: sticker.image)
        imageView.userInteractionEnabled = true
        if let size = overlayConverter?.initialSizeForStickerImage(sticker.image, containerView: stickersClipView) {
            imageView.frame.size = size
        }
        imageView.center = CGPoint(x: stickersClipView.bounds.midX, y: stickersClipView.bounds.midY)

        let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
        let scaleX = 1.0 / cropRect.width
        let scaleY = 1.0 / cropRect.height
        let scale = min(scaleX, scaleY)
        imageView.frame.size.width *= scale
        imageView.frame.size.height *= scale

        stickersClipView.addSubview(imageView)
        imageView.transform = CGAffineTransformMakeScale(0, 0)

        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            imageView.transform = CGAffineTransformMakeScale(1.0 / scale, 1.0 / scale)
            }, completion: nil)
    }
}

extension StickersEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }

        return false
    }
}
