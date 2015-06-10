//
//  IMGLYEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

internal let PhotoProcessorQueue = dispatch_queue_create("ly.img.SDK.PhotoProcessor", DISPATCH_QUEUE_SERIAL)

public class IMGLYEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    public var shouldShowActivityIndicator = true
    
    public var updating = false {
        didSet {
            if shouldShowActivityIndicator {
                dispatch_async(dispatch_get_main_queue()) {
                    if self.updating {
                        self.activityIndicatorView.startAnimating()
                    } else {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    public var lowResolutionImage: UIImage?
    
    public private(set) lazy var previewImageView: IMGLYZoomingImageView = {
        let imageView = IMGLYZoomingImageView()
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.userInteractionEnabled = self.enableZoomingInPreviewImage
        return imageView
        }()
    
    public private(set) lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        view.hidesWhenStopped = true
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        return view
    }()
    
    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItems()
        configureViewHierarchy()
        configureViewConstraints()
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return .Portrait
    }
    
    // MARK: - Configuration
    
    private func configureNavigationItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "tappedDone:")
    }
    
    private func configureViewHierarchy() {
        view.backgroundColor = UIColor.blackColor()

        view.addSubview(previewImageView)
        view.addSubview(bottomContainerView)
        previewImageView.addSubview(activityIndicatorView)
    }
    
    private func configureViewConstraints() {
        let views: [NSObject: AnyObject] = [
            "previewImageView" : previewImageView,
            "bottomContainerView" : bottomContainerView,
            "topLayoutGuide" : topLayoutGuide
        ]
        
        let metrics: [NSObject: NSNumber] = [
            "bottomContainerViewHeight" : 100
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[previewImageView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomContainerView]|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][previewImageView][bottomContainerView(==bottomContainerViewHeight)]|", options: nil, metrics: metrics, views: views))
        
        previewImageView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterX, multiplier: 1, constant: 0))
        previewImageView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    public var enableZoomingInPreviewImage: Bool {
        // Subclasses should override this to enable zooming
        return false
    }
    
    // MARK: - Actions
    
    public func tappedDone(sender: UIBarButtonItem?) {
        // Subclasses must override this
    }
    
}
