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

public class IMGLYStickersEditorViewController: IMGLYSubEditorViewController {

    // MARK: - Properties
    
    public let stickersDataSource = IMGLYStickersDataSource()
    public private(set) lazy var stickersClipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
        }()
    
    private var draggedView: UIView?
    private var initialCenterOfDraggedView = CGPointZero
    private var initialSizeOfPinchedView = CGSizeZero
    
    // MARK: - SubEditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        var addedStickers = false
        
        for view in stickersClipView.subviews as! [UIView] {
            if let view = view as? UIImageView {
                let stickerFilter = IMGLYInstanceFactory.sharedInstance.stickerFilter()
                stickerFilter.sticker = view.image
                stickerFilter.position = CGPoint(x: view.frame.origin.x / stickersClipView.frame.size.width, y: view.frame.origin.y / stickersClipView.frame.size.height)
                stickerFilter.size = CGSize(width: view.frame.size.width / stickersClipView.frame.size.width, height: view.frame.size.height / stickersClipView.frame.size.height)
                fixedFilterStack.stickerFilters.append(stickerFilter)
                addedStickers = true
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
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("stickers-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
        
        configureStickersCollectionView()
        configureStickersClipView()
        configureGestureRecognizers()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stickersClipView.frame = view.convertRect(previewImageView.imgly_imageFrame, fromView: previewImageView)
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
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.dataSource = stickersDataSource
        collectionView.delegate = self
        collectionView.registerClass(IMGLYStickerCollectionViewCell.self, forCellWithReuseIdentifier: StickersCollectionViewCellReuseIdentifier)
        
        let views = [ "collectionView" : collectionView ]
        bottomContainerView.addSubview(collectionView)
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[collectionView]|", options: nil, metrics: nil, views: views))
        bottomContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: nil, metrics: nil, views: views))
    }
    
    private func configureStickersClipView() {
        view.addSubview(stickersClipView)
    }
    
    private func configureGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panned:")
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        stickersClipView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinched:")
        stickersClipView.addGestureRecognizer(pinchGestureRecognizer)
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
    
    @objc private func pinched(recognizer: UIPinchGestureRecognizer) {
        if recognizer.numberOfTouches() == 2 {
            let point1 = recognizer.locationOfTouch(0, inView: stickersClipView)
            let point2 = recognizer.locationOfTouch(1, inView: stickersClipView)
            let midpoint = CGPoint(x:(point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
            let scale = recognizer.scale
            
            switch recognizer.state {
            case .Began:
                draggedView = stickersClipView.hitTest(midpoint, withEvent: nil) as? UIImageView
                if let draggedView = draggedView {
                    stickersClipView.bringSubviewToFront(draggedView)
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

extension IMGLYStickersEditorViewController: UICollectionViewDelegate {
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let sticker = stickersDataSource.stickers[indexPath.row]
        let imageView = UIImageView(image: sticker.image)
        imageView.userInteractionEnabled = true
        
        let initialMaxStickerSize = CGRectGetWidth(stickersClipView.bounds) * 0.3
        let widthRatio = initialMaxStickerSize / sticker.image.size.width
        let heightRatio = initialMaxStickerSize / sticker.image.size.height
        let scale = min(widthRatio, heightRatio)
        
        imageView.frame.size = CGSize(width: sticker.image.size.width * scale, height: sticker.image.size.height * scale)
        imageView.center = CGPoint(x: CGRectGetMidX(stickersClipView.bounds), y: CGRectGetMidY(stickersClipView.bounds))
        stickersClipView.addSubview(imageView)
        imageView.transform = CGAffineTransformMakeScale(0, 0)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            imageView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}
