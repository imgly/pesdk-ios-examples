//
//  IMGLYStickersEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

let StickersCollectionViewCellSize = CGSize(width: 90, height: 90)
let StickersCollectionViewCellReuseIdentifier = "StickersCollectionViewCell"

@objc public class IMGLYStickersEditorViewControllerOptions: IMGLYEditorViewControllerOptions {
    
    // MARK: Behaviour
    
    /// An object conforming to the `IMGLYStickersDataSourceProtocol`
    /// Per default an `IMGLYStickersDataSource` offering all filters
    /// is set.
    public var stickersDataSource: IMGLYStickersDataSourceProtocol = IMGLYStickersDataSource()
    
    /// Disables/Enables the pinch gesture on stickers to change their size.
    public var canModifyStickerSize = true
    
    public override init() {
        super.init()
        
        /// Override inherited properties with default values
        self.title = NSLocalizedString("stickers-editor.title", tableName: nil, bundle: NSBundle(forClass: IMGLYMainEditorViewController.self), value: "", comment: "")
    }
}

public class IMGLYStickersEditorViewController: IMGLYSubEditorViewController {

    // MARK: - Properties
    
    public var stickersDataSource = IMGLYStickersDataSource()
    public private(set) lazy var stickersClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
        }()
    
    private var draggedView: UIView?
    private var tempStickerCopy = [CIFilter]()
    
    // MARK: - IMGLYEditorViewController
    
    public override var options: IMGLYStickersEditorViewControllerOptions {
        return self.configuration.stickersEditorViewControllerOptions
    }
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        var addedStickers = false
        
        for view in stickersClipView.subviews {
            if let view = view as? UIImageView {
                if let image = view.image {
                    let stickerFilter = IMGLYInstanceFactory.stickerFilter()
                    stickerFilter.sticker = image
                    stickerFilter.cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
                    let cropRect = stickerFilter.cropRect
                    let completeSize = stickersClipView.bounds.size
                    var center = CGPoint(x: view.center.x / completeSize.width,
                                         y: view.center.y / completeSize.height)
                    center.x *= cropRect.width
                    center.y *= cropRect.height
                    center.x += cropRect.origin.x
                    center.y += cropRect.origin.y
                    var size = initialSizeForStickerImage(image)
                    size.width = size.width / completeSize.width
                    size.height = size.height / completeSize.height
                    stickerFilter.center = center
                    stickerFilter.scale = size.width
                    stickerFilter.transform = view.transform
                    fixedFilterStack.stickerFilters.append(stickerFilter)
                    addedStickers = true
                }
            }
        }
        
        if addedStickers {
            updatePreviewImageWithCompletion {
                self.stickersClipView.removeFromSuperview()
                super.tappedDone(sender)
            }
        } else {
            super.tappedDone(sender)
        }
    }
    
    // MARK: - Helpers
    
    private func initialSizeForStickerImage(image: UIImage) -> CGSize {
        let initialMaxStickerSize = CGRectGetWidth(stickersClipView.bounds) * 0.3
        let widthRatio = initialMaxStickerSize / image.size.width
        let heightRatio = initialMaxStickerSize / image.size.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: image.size.width * scale, height: image.size.height * scale)
    }
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
                
        configureStickersCollectionView()
        configureStickersClipView()
        configureGestureRecognizers()
        backupStickers()
        fixedFilterStack.stickerFilters.removeAll()
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
    
    private func configureStickersCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = StickersCollectionViewCellSize
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = currentBackgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(IMGLYStickerCollectionViewCell.self, forCellWithReuseIdentifier: StickersCollectionViewCellReuseIdentifier)
        
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
            draggedView = stickersClipView.hitTest(location, withEvent: nil) as? UIImageView
            if let draggedView = draggedView {
                stickersClipView.bringSubviewToFront(draggedView)
            }
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            }
            
            recognizer.setTranslation(CGPointZero, inView: stickersClipView)
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
                    draggedView = stickersClipView.hitTest(midpoint, withEvent: nil) as? UIImageView
                }
                
                if let draggedView = draggedView {
                    stickersClipView.bringSubviewToFront(draggedView)
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
                    draggedView = stickersClipView.hitTest(midpoint, withEvent: nil) as? UIImageView
                }
                
                if let draggedView = draggedView {
                    stickersClipView.bringSubviewToFront(draggedView)
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
    
    
    // MARK: - sticker object restore
    
    private func rerenderPreviewWithoutStickers() {
        updatePreviewImageWithCompletion { () -> (Void) in
            self.addStickerImagesFromStickerFilters(self.tempStickerCopy)
        }
    }
 
    /* 
    * in this method we do some calculations to re calculate the
    * sticker position in relation to the crop region.
    * Therefore we calculte the position and size within the non-cropped image
    * and apply the translation and scaling that comes with cropping in relation
    * to the full image.
    * When we are done we must revoke that extra transformation.
    */
    private func addStickerImagesFromStickerFilters(stickerFilters: [CIFilter]) {
        for element in stickerFilters {
            guard let stickerFilter = element as? IMGLYStickerFilter else {
                return
            }
            let imageView = UIImageView(image: stickerFilter.sticker)
            imageView.userInteractionEnabled = true
            let cropRect = self.fixedFilterStack.orientationCropFilter.cropRect
            var completeSize = stickersClipView.bounds.size
            completeSize.width *= 1.0 / cropRect.width
            completeSize.height *= 1.0 / cropRect.height
            let size = stickerFilter.absolutStickerSizeForImageSize(completeSize)
            imageView.frame.size = size
            print(stickerFilter.center)
            var center = CGPoint(x: stickerFilter.center.x * completeSize.width,
                                 y: stickerFilter.center.y * completeSize.height)
            center.x -= (cropRect.origin.x * completeSize.width)
            center.y -= (cropRect.origin.y * completeSize.height)
            imageView.center = center
            imageView.transform = stickerFilter.transform
            stickersClipView.addSubview(imageView)
        }
    }
    
    private func backupStickers() {
        tempStickerCopy = fixedFilterStack.stickerFilters
    }
}

extension IMGLYStickersEditorViewController: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.stickersDataSource.stickerCount
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickersCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! IMGLYStickerCollectionViewCell
        
        let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
        cell.imageView.image = sticker.thumbnail ?? sticker.image
        
        return cell
    }
}

extension IMGLYStickersEditorViewController: UICollectionViewDelegate {
    // add selected sticker
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let sticker = options.stickersDataSource.stickerAtIndex(indexPath.item)
        let imageView = UIImageView(image: sticker.image)
        imageView.userInteractionEnabled = true
        imageView.frame.size = initialSizeForStickerImage(sticker.image)
        imageView.center = CGPoint(x: CGRectGetMidX(stickersClipView.bounds), y: CGRectGetMidY(stickersClipView.bounds))
        
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

extension IMGLYStickersEditorViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) || (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        
        return false
    }
}