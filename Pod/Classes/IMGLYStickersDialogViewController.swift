    //
//  IMGLYStickersDialogViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 23/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

let kStickerCollectionViewCellReuseIdentifier = "StickerCollectionViewCell"

public class IMGLYStickersDialogViewController: UIViewController, IMGLYSubEditorViewControllerProtocol, IMGLYStickersDialogViewDelegate, UICollectionViewDelegate {
    
    // MARK: - Accessors
    
    private var filteredImage: UIImage?
    private var draggedView: UIView?
    private var initialCenterOfDraggedView = CGPointZero
    private var initialSizeOfPinchedView = CGSizeZero
    private var dialogView_: IMGLYStickersDialogView?
    public var stickersDataSource: IMGLYStickersDataSourceDelegate = IMGLYStickersDataSource() {
        didSet {
            if isViewLoaded() {
                dialogView_!.collectionView.dataSource = stickersDataSource
            }
        }
    }
    private var collectionView: UICollectionView? {
        return dialogView_?.collectionView
    }
    
    // MARK: - IMGLYSubEditorViewControllerProtocol
    
    public var previewImage: UIImage?
    public var completionHandler: IMGLYSubEditorCompletionBlock?
    public var fixedFilterStack: FixedFilterStack?
    public var dialogView: UIView? {
        get {
            return view
        }
        set(newView) {
            view = newView
        }
    }
    
    // MARK: - UIViewController
    
    public override func loadView() {
        self.view = IMGLYStickersDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        dialogView_ = self.view as? IMGLYStickersDialogView
        if dialogView_ != nil {
            dialogView_!.delegate = self
            collectionView?.dataSource = stickersDataSource
            collectionView?.delegate = self
            filteredImage = previewImage
            updatePreviewImage()
            configureCollectionView()
            configureGestureRecognizers()
        }
    }
    
    // MARK: - IMGLYStickersDialogViewDelegate
    
    public func doneButtonPressed() {
        if let completionHandler = completionHandler {
            for view in dialogView_?.stickersClipView.subviews as! [UIView] {
                if let view = view as? UIImageView {
                    let stickerFilter = IMGLYInstanceFactory.sharedInstance.stickerFilter()
                    stickerFilter.sticker = view.image
                    stickerFilter.position = CGPoint(x: view.frame.origin.x / CGRectGetWidth(dialogView_!.stickersClipView.frame), y: view.frame.origin.y / CGRectGetHeight(dialogView_!.stickersClipView.frame))
                    stickerFilter.size = CGSize(width: view.frame.size.width / CGRectGetWidth(dialogView_!.stickersClipView.frame), height: view.frame.size.height / CGRectGetHeight(dialogView_!.stickersClipView.frame))
                    fixedFilterStack!.stickerFilters.append(stickerFilter)
                }
            }
            
            filteredImage = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
            completionHandler(.Done, filteredImage)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        completionHandler?(.Cancel, nil)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    // MARK: - Helpers
    
    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panned:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        dialogView_!.stickersClipView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinched:")
        dialogView_!.stickersClipView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    private func updatePreviewImage() {
        if fixedFilterStack != nil {
            filteredImage = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
            dialogView_!.previewImageView.image = filteredImage
        }
    }
    
    private func configureCollectionView() {
        let nib = UINib(nibName: "IMGLYStickerCollectionViewCell", bundle: NSBundle(forClass: IMGLYStickerCollectionViewCell.self))
        collectionView?.registerNib(nib, forCellWithReuseIdentifier: kStickerCollectionViewCellReuseIdentifier)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let sticker = stickersDataSource.stickers[indexPath.row]
        let imageView = UIImageView(image: sticker.image)
        imageView.userInteractionEnabled = true
        
        let initialMaxStickerSize = CGRectGetWidth(dialogView_!.stickersClipView.bounds) * 0.3
        let widthRatio = initialMaxStickerSize / sticker.image.size.width
        let heightRatio = initialMaxStickerSize / sticker.image.size.height
        let scale = min(widthRatio, heightRatio)
        
        imageView.frame.size = CGSize(width: sticker.image.size.width * scale, height: sticker.image.size.height * scale)
        imageView.center = CGPoint(x: CGRectGetMidX(dialogView_!.stickersClipView.bounds), y: CGRectGetMidY(dialogView_!.stickersClipView.bounds))
        dialogView_!.stickersClipView.addSubview(imageView)
        imageView.transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            imageView.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    // MARK: - Gesture Handling
    
    func panned(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(dialogView_!.stickersClipView)
        let translation = recognizer.translationInView(dialogView_!.stickersClipView)
        
        switch recognizer.state {
        case .Began:
            draggedView = dialogView_!.stickersClipView.hitTest(location, withEvent: nil) as? UIImageView
            if let draggedView = draggedView {
                dialogView_!.stickersClipView.bringSubviewToFront(draggedView)
                initialCenterOfDraggedView = draggedView.center
            }
        case .Changed:
            if let draggedView = draggedView {
                draggedView.center = CGPoint(x: initialCenterOfDraggedView.x + translation.x, y: initialCenterOfDraggedView.y + translation.y)
            }
        case .Cancelled, .Ended:
            initialCenterOfDraggedView = CGPointZero
            draggedView = nil
        default:
            break
        }
    }
    
    func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: dialogView_!.stickersClipView)
            let point2 = recognizer.locationOfTouch(1, inView: dialogView_!.stickersClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale
            
            switch recognizer.state {
            case .Began:
                draggedView = dialogView_!.stickersClipView.hitTest(midpoint, withEvent: nil) as? UIImageView
                if let draggedView = draggedView {
                    dialogView_!.stickersClipView.bringSubviewToFront(draggedView)
                    initialSizeOfPinchedView = draggedView.frame.size
                }
            case .Changed:
                if let draggedView = draggedView {
                    let center = draggedView.center
                    draggedView.frame.size = CGSize(width: initialSizeOfPinchedView.width * scale, height: initialSizeOfPinchedView.height * scale)
                    draggedView.center = center
                }
            case .Cancelled, .Ended:
                initialSizeOfPinchedView = CGSizeZero
                draggedView = nil
            default:
                break
            }
        }
    }
}
