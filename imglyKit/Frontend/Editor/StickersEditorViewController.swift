//
//  StickersEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

let kStickersCollectionViewCellSize = CGSize(width: 90, height: 90)
// swiftlint:disable variable_name
let kStickersCollectionViewCellReuseIdentifier = "StickersCollectionViewCell"
// swiftlint:enable variable_name

@objc(IMGLYStickersEditorViewController) public class StickersEditorViewController: SubEditorViewController {

    // MARK: - Properties

    public var stickersDataSource = StickersDataSource()
    public private(set) lazy var stickersClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
        }()

    private var draggedView: UIImageView?
    private var tempStickerCopy = [Filter]()
    private var overlayConverter: OverlayConverter?
    private var selectedView = UIImageView()

    public private(set) lazy var deleteButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "deleteSticker:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var flipHorizontalButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipHorizontal:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var flipVerticalButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "flipVertical:", forControlEvents: .TouchUpInside)
        return button
    }()

    public private(set) lazy var bringToFrontButton: UIButton = {
        let bundle = NSBundle(forClass: self.dynamicType)
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "icon_crop_custom", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: "bringToFront:", forControlEvents: .TouchUpInside)
        return button
    }()

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
        configureOverlayButtons()
        backupStickers()
        fixedFilterStack.spriteFilters.removeAll()
        updateButtonStatus()
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
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        stickersClipView.addGestureRecognizer(panGestureRecognizer)

        if options.canModifyStickerSize {
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
            pinchGestureRecognizer.delegate = self
            stickersClipView.addGestureRecognizer(pinchGestureRecognizer)
        }

        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
        rotationGestureRecognizer.delegate = self
        stickersClipView.addGestureRecognizer(rotationGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGestureRecognizer.delegate = self
        stickersClipView.addGestureRecognizer(tapGestureRecognizer)
    }


    private func configureOverlayButtons() {
        if options.canDeleteSticker {
            configureDeleteButton()
        }
        if options.canFlipHorizontaly {
            configureFlipHorizontalButton()
        }
        if options.canFlipVerticaly {
            configureFlipVerticalButton()
        }
        if options.canBringToFront {
            configureBringToFrontButton()
        }
        configureOverlayButtonHorizontalConstraints()
    }

    private func configureDeleteButton() {
        let views: [String : AnyObject] = [
            "deleteButton" : deleteButton
        ]
        view.addSubview(deleteButton)
        deleteButton.clipsToBounds = false
        deleteButton.backgroundColor = options.deleteButtonBackgroundColor
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[deleteButton]-20-|", options: [], metrics: [ "buttonWidth": 30 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[deleteButton(40)]", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20))
    }

    private func configureFlipHorizontalButton() {
        let views: [String : AnyObject] = [
            "flipHorizontalButton" : flipHorizontalButton
        ]
        view.addSubview(flipHorizontalButton)
        flipHorizontalButton.clipsToBounds = false
        flipHorizontalButton.backgroundColor = options.flipHorizontalButtonBackgroundColor
  //      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-20-[flipHorizontalButton]", options: [], metrics: [ "buttonWidth": 30 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[flipHorizontalButton(40)]", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: flipHorizontalButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20))
    }

    private func configureFlipVerticalButton() {
        let views: [String : AnyObject] = [
            "flipVerticalButton" : flipVerticalButton
        ]
        view.addSubview(flipVerticalButton)
        flipVerticalButton.clipsToBounds = false
        flipVerticalButton.backgroundColor = options.flipVerticalButtonBackgroundColor
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-80-[flipVerticalButton]", options: [], metrics: [ "buttonWidth": 30 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[flipVerticalButton(40)]", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: flipVerticalButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20))
    }

    private func configureBringToFrontButton() {
        let views: [String : AnyObject] = [
            "bringToFrontButton" : bringToFrontButton
        ]
        view.addSubview(bringToFrontButton)
        bringToFrontButton.clipsToBounds = false
        bringToFrontButton.backgroundColor = options.bringToFrontButtonBackgroundColor
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[bringToFrontButton]-80-|", options: [], metrics: [ "buttonWidth": 30 ], views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bringToFrontButton(40)]", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: bringToFrontButton, attribute: .Bottom, relatedBy: .Equal, toItem: bottomContainerView, attribute: .Top, multiplier: 1, constant: -20))
    }

    private func configureOverlayButtonHorizontalConstraints() {
        configureLeftOverlayButtonHorizontalConstraints()
        configureRightOverlayButtonHorizontalConstraints()
    }

    private func configureLeftOverlayButtonHorizontalConstraints() {
        var leftButtons: [UIButton] = []
        if options.canFlipHorizontaly {
            leftButtons.append(flipHorizontalButton)
        }
        if options.canFlipVerticaly {
            leftButtons.append(flipVerticalButton)
        }
        setOverlayButtonConstraints(leftButtons, prefix: "|-20-", suffix: "")
    }

    private func configureRightOverlayButtonHorizontalConstraints() {
        var rightButtons: [UIButton] = []
        if options.canBringToFront {
            rightButtons.append(bringToFrontButton)
        }
        if options.canDeleteSticker {
            rightButtons.append(deleteButton)
        }
        setOverlayButtonConstraints(rightButtons, prefix: "", suffix: "-20-|")
    }

    private func setOverlayButtonConstraints(buttons: [UIButton], prefix: String, suffix: String) {
        if buttons.count == 1 {
            let views: [String : AnyObject] = [
                "button1" : buttons[0]
            ]
            let string = "\(prefix)[button1]\(suffix)"
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(string, options: [], metrics: [ "buttonWidth": 30 ], views: views))
        } else if buttons.count == 2 {
            let views: [String : AnyObject] = [
                "button1" : buttons[0],
                "button2" : buttons[1]
            ]
            let string = "\(prefix)[button1]-20-[button2]\(suffix)"
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(string, options: [], metrics: [ "buttonWidth": 30 ], views: views))
        }
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(stickersClipView)
        let translation = recognizer.translationInView(stickersClipView)

        switch recognizer.state {
        case .Began:
            draggedView = hitImageView(location)
            if let draggedView = draggedView {
                unSelectView(selectedView)
                selectedView = draggedView
                selectView(selectedView)
            }
            updateButtonStatus()
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

    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
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
                if let draggedView = draggedView {
                    unSelectView(selectedView)
                    selectedView = draggedView
                    selectView(selectedView)
                }
                updateButtonStatus()
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

    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
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
                if let draggedView = draggedView {
                    unSelectView(selectedView)
                    selectedView = draggedView
                    selectView(selectedView)
                    updateButtonStatus()
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

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(stickersClipView)
        draggedView = hitImageView(location)
        unSelectView(selectedView)
        if let draggedView = draggedView {
            selectedView = draggedView
            selectView(selectedView)
        }
        updateButtonStatus()
    }


    // MARK:- Button-handling
     @objc private func deleteSticker(sender: UIButton) {
        if selectedView.layer.borderWidth > 0 {
            selectedView.removeFromSuperview()
        }
        updateButtonStatus()
    }

    @objc private func bringToFront(sender: UIButton) {
        if selectedView.layer.borderWidth > 0 {
            stickersClipView.bringSubviewToFront(selectedView)
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

    private func selectView(imageView: UIImageView) {
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = 1.0
    }

    private func unSelectView(imageView: UIImageView) {
        imageView.layer.borderWidth = 0
    }

    private func updateButtonStatus() {
        let enabled = selectedView.layer.borderWidth > 0
        let alpha = CGFloat( enabled ? options.enabledOverlayButtonAlpha : options.disabledOverlayButtonAlpha )
        deleteButton.alpha = alpha
        deleteButton.enabled = enabled
        flipVerticalButton.alpha = alpha
        flipVerticalButton.enabled = enabled
        flipHorizontalButton.alpha = alpha
        flipHorizontalButton.enabled = enabled
        bringToFrontButton.alpha = alpha
        bringToFrontButton.enabled = enabled
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
        unSelectView(selectedView)
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
            }, completion: { (Bool) -> Void in
                self.selectedView = imageView
                self.selectView(imageView)
                self.updateButtonStatus()
        })
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
