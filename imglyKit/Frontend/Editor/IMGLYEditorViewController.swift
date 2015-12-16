//
//  IMGLYEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

internal let PhotoProcessorQueue = dispatch_queue_create("ly.img.SDK.PhotoProcessor", DISPATCH_QUEUE_SERIAL)

@objc public class IMGLYEditorViewControllerOptions: NSObject {
    
    ///  Defaults to 'Editor'
    public lazy var title: String? = "Editor"
    
    /// The viewControllers backgroundColor. Defaults to the configurations
    /// global background color.
    public var backgroundColor: UIColor?
    
    /**
     A configuration closure to configure the given left bar button item.
     Defaults to a 'Cancel' in the apps tintColor or 'Back' when presented within
     a navigation controller.
     */
    public lazy var leftBarButtonConfigurationClosure: IMGLYBarButtonItemConfigurationClosure = { _ in }
    
    /**
     A configuration closure to configure the given done button item.
     Defaults to 'Editor' in the apps tintColor.
     */
    public lazy var rightBarButtonConfigurationClosure: IMGLYBarButtonItemConfigurationClosure = { _ in }
    
    /// Controls if the user can zoom the preview image. Defaults to **true**.
    public lazy var allowsPreviewImageZoom = true
}

public class IMGLYEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    var configuration: IMGLYConfiguration = IMGLYConfiguration()
    
    public var shouldShowActivityIndicator = true
    
    var options: IMGLYEditorViewControllerOptions {
        // Must be implemented in subclass
        return IMGLYEditorViewControllerOptions()
    }
    
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
        imageView.backgroundColor = self.configuration.backgroundColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.userInteractionEnabled = self.enableZoomingInPreviewImage
        return imageView
        }()
    
    public private(set) lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = self.view.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initalization
    
    /**
    This is the designated initializer that accepts an IMGLYConfiguration
    
    - parameter configuration: An IMGLYConfiguration object
    
    - returns: An initialized EditorViewController
    */
    init(configuration: IMGLYConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.configuration = configuration
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
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
        if let navBar = self.navigationController?.navigationBar {
            navBar.barTintColor = self.configuration.backgroundColor
        }
        
        view.backgroundColor = self.configuration.backgroundColor

        view.addSubview(previewImageView)
        view.addSubview(bottomContainerView)
        previewImageView.addSubview(activityIndicatorView)
    }
    
    private func configureViewConstraints() {
        let views: [String: AnyObject] = [
            "previewImageView" : previewImageView,
            "bottomContainerView" : bottomContainerView,
            "topLayoutGuide" : topLayoutGuide
        ]
        
        let metrics: [String: AnyObject] = [
            "bottomContainerViewHeight" : 100
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[previewImageView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[bottomContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][previewImageView][bottomContainerView(==bottomContainerViewHeight)]|", options: [], metrics: metrics, views: views))
        
        previewImageView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterX, multiplier: 1, constant: 0))
        previewImageView.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: previewImageView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    var enableZoomingInPreviewImage: Bool {
        return options.allowsPreviewImageZoom
    }
    
    // MARK: - Actions
    
    public func tappedDone(sender: UIBarButtonItem?) {
        // Subclasses must override this
    }
    
}
